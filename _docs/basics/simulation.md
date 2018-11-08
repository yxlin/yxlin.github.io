---
title: Simulation
category: Modelling Basics
order: 2
---

This tutorial has two sections.  First section demonstrates the method of
simulating the data for a imaginary participant. _simulate_ creates a
(R) data frame based on the parameter vector and the model with _nsim_
observations for each row in model. _ps_ is the true parameter vector.

Second section shows how to conduct a process model. Specifically, the
second section conducts a simulation experiment to describe an example
(the _British tea_ example, p 37, Maxwell & Delaney, 2004). See
Maxwell and Delaney (2004) for an analytic way to calculate the same
probabilities. Here I use a direct simulation to get approximately
the same probabilities.

## One-participant simulation

```
model <- BuildModel(
   p.map     = list(A = "1", B = "R", t0 = "1", mean_v = "M", sd_v = "M", st0 = "1"),
   match.map = list(M = list(s1 = "r1", s2 = "r2")),
   factors   = list(S = c("s1", "s2")),
   constants = c(sd_v.false = 1, st0 = 0),
   responses = c("r1", "r2"),
   type      = "norm")
   
p.vector  <- c(A = .75, B.r1 = .25, B.r2 = .15, t0 = .2, mean_v.true = 2.5,
               mean_v.false = 1.5, sd_v.true = 0.5)

set.seed(123)  ## Set seed to get the same simulation
dat <- simulate(model, nsim = 1, ps = p.vector)

##    S  R        RT
## 1 s1 r1 0.3327392
## 2 s2 r1 0.3797985

```


Simulate 100 responses for each condition. In this model, I
generated 200 responses in total.

```
ntrial <- 1e2
dat <- simulate(model, nsim = ntrial, ps = p.vector)
data.table::data.table(dat)
##       S  R        RT
##   1: s1 r2 0.5228495
##   2: s1 r1 0.4627093
##   3: s1 r1 0.4418045
##   4: s1 r1 0.5376318
##   5: s1 r1 0.3119197
##  ---                
## 196: s2 r2 0.3706081
## 197: s2 r1 0.4762363
## 198: s2 r1 0.4797071
## 199: s2 r2 0.5076515
## 200: s2 r2 0.3883532
```


Model and data are two separate objects. To fit data with a certain model,
I bind them together with _BindDataModel_.  This is to facilitate model
comparison. That is, a data set can bind with many different models, so
we can compare them to see which model may fit the data better or provide
a better account. I used a term, data-model instance (dmi),
coined by Matthew Gretton. 

```
dmi <- BindDataModel(dat, model)
```


We can use DMC's base plot function to check the accuracy and RT distributions
for each stimulus level. Correct responses are in black and error responses are
in red.

```
par(mfrow = c(1, 2), mar = c(4, 5.3, 0.82, 1))
plot.cell.density(dmi[dmi$S=="s1",], C="r1", xlim=c(0,4))
plot.cell.density(dmi[dmi$S=="s2",], C="r2", xlim=c(0,4))
par(mfrow=c(1, 1))

```

![distributions]({{"/images/simulation/density.png" | relative_url}})


## British tea example

Quoted from Maxwell and Delaney (p. 37, 2004)

>"A lady declares that by tasting a cup of tea made with milk, she can
> discriminate whether the milk or the tea infusion was first added to the cup.
> We will consider the problem of designing an experiment by means of which this
> assertion can be tested. (Fisher, 1935/1971, p. 11)"

This following function, _British.tea_ implements a process model to
describe the above "British tea example". That is, it conducts a simulation
experiment of presenting 8 (i.e., n) cups of tea to a participant. The task is
to decide one cup after another if a cup of tea is made by adding tea or milk
first. One additional information (i.e., assumption) is that the participant is
told half of the cups are milk first and tea and vice versa. So when simulating
the chance only scenario, we need also to take this into consideration. That is,
after making a decision for a cup (either MT or TM), the (chance) probability
state should adjust accordingly.

```
British.tea <- function(n = 8, correct = c(1,1,1,1, 0,0,0,0),
                        verbose = TRUE) {
    ## obs, default number of observation is 8 (cups of tea)
    ## correct, define a default correct sequence: First four cups are tea and 
    ## milk. The next four cups are milk and then tea.
    MT <- n/2 ## 0 indicates milk and then tea (MT)
    TM <- n/2 ## 1 indicates tea and then milk (TM)

    ## Create three containers
    ## 1. a "n x 2" matrix to store the evolution of chance probabilities
    ## 2. n-element numeric vector
    ## 3. a n logical vector; default value is FALSE
    x0 <- matrix(numeric(n*2), ncol = 2)
    res <- numeric(n)
    acc <- rep(FALSE, n)

    ## Begin the experiment, presenting one cup after another
    for (i in 1:n) {
        if (verbose) cat("Cup", i, "in total", sum(MT, TM), " cup(s)\n")
        
        probMT <- MT / (MT + TM)   ## chance probability of MT 
        probTM <- TM / (MT + TM)   ## chance probability of TM
        probs  <- c(probMT, probTM)
        
        if (verbose) cat("Chances probabilities of (MT, TM): ", probs, "\n")
        
        x0[i, ] <- probs
        decision <- sample(c(0, 1), 1, replace = TRUE, prob = probs);
         if (decision == 0) {
             if (verbose) cat("This cup is made by adding milk first\n")
             MT <- MT - 1
             res[i] <- decision
             if (decision == correct[i]) acc[i] <- TRUE
         } else if (decision == 1) {
             if (verbose) cat("This cup is made by adding tea first\n")
             TM <- TM - 1
             res[i] <- decision
             if (decision == correct[i]) acc[i] <- TRUE
         } else cat("Unexpected situation\n")
         
         if (verbose) cat("Current state", i, ": ", c(MT, TM), "\n\n")
    }
    if (verbose) cat("Done\n")
    return(list(x0, res, correct, acc))
}

################################################50
## Conduct one experiment and print information
################################################50
ncup <- 8
cor <- c(rep(1, 4), rep(0, 4)); 
res <- British.tea(ncup, cor, TRUE)

################################################50
## Replicate the experiments separately for,
## 64, 512, 4096, 32768 and 262144 times
################################################50
n <- 8^(3:7); n

exp <- vector("list", length(n))

## Use parallel package to conduct experiments
## 100.636 s
library(parallel)
cl <- makeCluster(detectCores())
clusterExport(cl, c("British.tea", "ncup", "cor"))
system.time(
    for (i in 1:length(n)) {
        exp[[i]] <- parSapply(cl, 1:n[i], function(i, ...) {British.tea(ncup, cor, FALSE)} )
    }
)
stopCluster(cl)
## Without using parallel
## for(i in 1:length(n)) {
##     exp[[i]] <- replicate(n[i], British.tea(ncup, cor, FALSE))
## }

res3 <- numeric(length(n)); res3  ## to store the result when 6 corrects
res4 <- numeric(length(n)); res4  ## to store the result when 8 corrects

## Collect results
for(i in 1:length(n)) {
    c3 <- 0
    c4 <- 0
    for(j in 1:n[i]) {
         ## Calculate exactly 4 corrects
         if(all(exp[[i]][,j][[4]])) c4 <- c4 + 1
         if(sum(exp[[i]][,j][[4]]) == 6) c3 <- c3 + 1
    }
    res3[i] <- c3 / n[i]
    res4[i] <- c4 / n[i]
}


round(res3, 4) ## [1] 0.2578 0.2324 0.2306 0.2288 0.2286
round(res4, 4) ## [1] 0.0137 0.0137 0.0140 0.0141 0.0143
## Plot the result
## (How to add differernt horizontal lines on each facet)
DT <- data.table(x= rep(n, 2), y = c(res3, res4), gp = rep(c("6", "8"), each = 5),
                 ref = rep(c(16/70, 1/70), each = 5))

## Dashlines show theoretically probabilities
p0 <- ggplot(DT, aes(x, y)) +
    geom_point(size = 3) +
    geom_hline(aes(yintercept = ref), linetype = "dashed") +
    ## scale_x_log10(name = "N") +
    xlab("N") + ylab("Probability") +
    facet_grid(gp~., scales = "free") +
    theme_bw(base_size = 22) 

print(p0)

```

![tea]({{"/images/simulation/tea.png" | relative_url}})
