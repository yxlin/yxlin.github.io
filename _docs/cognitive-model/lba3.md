---
title: Three-accumulator LBA Model
category: Cognitive Model
order: 7
---

> We have striven to minimize the number of errors. However, we canot 
> guarantee the note is 100% accurate.

This is a note for fitting 3-accumulator LBA model.

Some pre-analysis set up work.

```
## version 0.2.6.0
## install.packages("ggdmc")
loadedPackages <-c("ggdmc", "data.table", "ggplot2", "gridExtra", "ggthemes")
sapply(loadedPackages, require, character.only=TRUE)

## A function for generating posterior predict samples
predict_one <- function(object, npost = 100, rand = TRUE, factors = NA,
                        xlim = NA, seed = NULL)
{
  model <- attributes(object$data)$model
  facs <- names(attr(model, "factors"))
  class(object$data) <- c("data.frame", "list")
  
  if (!is.null(factors))
  {
    if (any(is.na(factors))) factors <- facs
    if (!all(factors %in% facs))
      stop(paste("Factors argument must contain one or more of:",
                 paste(facs, collapse=",")))
  }
  
  resp <- names(attr(model, "responses"))
  ns   <- table(object$data[,facs], dnn = facs)
  npar   <- object$n.pars
  nchain <- object$n.chains
  nmc    <- object$nmc
  ntsample <- nchain * nmc
  pnames   <- object$p.names
  
  thetas <- matrix(aperm(object$theta, c(3,2,1)), ncol = npar)
  
  colnames(thetas) <- pnames
  
  if (is.na(npost)) {
    use <- 1:ntfitple
  } else {
    if (rand) {
      use <- fitple(1:ntfitple, npost, replace = F)
    } else {
      use <- round(seq(1, ntfitple, length.out = npost))
    use <- 1:ntsample
  } else {
    if (rand) {
      use <- sample(1:ntsample, npost, replace = F)
    } else {
      use <- round(seq(1, ntsample, length.out = npost))
    }
  }
  
  npost  <- length(use)
  posts   <- thetas[use, ]
  nttrial <- sum(ns) ## number of total trials
  
  v <- lapply(1:npost, function(i) {
    ggdmc:::simulate_one(model, n = ns, ps = posts[i,], seed = seed)
  })
  out <- data.table::rbindlist(v)
  
  reps <- rep(1:npost, each = nttrial)
  out <- cbind(reps, out)
  
  if (!any(is.na(xlim)))
  {
    out <- out[RT > xlim[1] & RT < xlim[2]]
  }
  
  attr(out, "data") <- object$data
  return(out)
  }
  
```

In this example, we assumed three accumulators corresponding to three responses. 
Let's say they are "Word", "Nonword", or "Pseudo-word". They are coded 
respectively as W, N and P. This is to assume we had run some (visual) 
lexical-decision experiments, instructing participants to decide whether a 
stimulus is a word, a non-word, or a make-up word. The three types of stimuli 
are coded as ww, nn and pn.

```
model <- BuildModel(
  p.map     = list(A = "1", B = "1", t0 = "1", mean_v = "R", sd_v = "1",
                   st0 = "1"),
  match.map = list(M = list(ww = "W", nn = "N", pn = "P")),
  factors   = list(S = c("ww", "nn", "pn")),
  constants = c(st0 = 0, sd_v = 1),
  responses = c("W", "N", "P"),
  type      = "norm")
## Parameter vector names are: ( see attr(,"p.vector") )
## [1] "A"        "B"        "t0"       "mean_v.W" "mean_v.N" "mean_v.P"
## 
## Constants are (see attr(,"constants") ):
##  st0 sd_v 
##    0    1 
## 
## Model type = norm (posdrift = TRUE ) 
```


Firstly, as usual, we conducted a small recovery study. That is, we designated
a parameter vector with specific values and on the basis of this particular
parameter vector, we simulated a data set and fit such data set with the
model to see if it could recover the values reasonably well.

For now, we will show only the recovery study. We designated a true parameter
vector.

```
p.vector <- c(A = 1.25, B = .25, t0 = .2, mean_v.W = 2.5, mean_v.N = 1.5,
              mean_v.P = 1.2)

## ggdmc adapts print function to help inspect model
print(model)

## The model array is huge
## W 
##         A    B   t0 mean_v.W mean_v.N mean_v.P sd_v  st0
## ww.W TRUE TRUE TRUE     TRUE    FALSE    FALSE TRUE TRUE
## nn.W TRUE TRUE TRUE     TRUE    FALSE    FALSE TRUE TRUE
## pn.W TRUE TRUE TRUE     TRUE    FALSE    FALSE TRUE TRUE
## ww.N TRUE TRUE TRUE     TRUE    FALSE    FALSE TRUE TRUE
## nn.N TRUE TRUE TRUE     TRUE    FALSE    FALSE TRUE TRUE
## pn.N TRUE TRUE TRUE     TRUE    FALSE    FALSE TRUE TRUE
## ww.P TRUE TRUE TRUE     TRUE    FALSE    FALSE TRUE TRUE
## nn.P TRUE TRUE TRUE     TRUE    FALSE    FALSE TRUE TRUE
## pn.P TRUE TRUE TRUE     TRUE    FALSE    FALSE TRUE TRUE
## N 
##         A    B   t0 mean_v.W mean_v.N mean_v.P sd_v  st0
## ww.W TRUE TRUE TRUE    FALSE     TRUE    FALSE TRUE TRUE
## nn.W TRUE TRUE TRUE    FALSE     TRUE    FALSE TRUE TRUE
## pn.W TRUE TRUE TRUE    FALSE     TRUE    FALSE TRUE TRUE
## ww.N TRUE TRUE TRUE    FALSE     TRUE    FALSE TRUE TRUE
## nn.N TRUE TRUE TRUE    FALSE     TRUE    FALSE TRUE TRUE
## pn.N TRUE TRUE TRUE    FALSE     TRUE    FALSE TRUE TRUE
## ww.P TRUE TRUE TRUE    FALSE     TRUE    FALSE TRUE TRUE
## nn.P TRUE TRUE TRUE    FALSE     TRUE    FALSE TRUE TRUE
## pn.P TRUE TRUE TRUE    FALSE     TRUE    FALSE TRUE TRUE
## P 
##         A    B   t0 mean_v.W mean_v.N mean_v.P sd_v  st0
## ww.W TRUE TRUE TRUE    FALSE    FALSE     TRUE TRUE TRUE
## nn.W TRUE TRUE TRUE    FALSE    FALSE     TRUE TRUE TRUE
## pn.W TRUE TRUE TRUE    FALSE    FALSE     TRUE TRUE TRUE
## ww.N TRUE TRUE TRUE    FALSE    FALSE     TRUE TRUE TRUE
## nn.N TRUE TRUE TRUE    FALSE    FALSE     TRUE TRUE TRUE
## pn.N TRUE TRUE TRUE    FALSE    FALSE     TRUE TRUE TRUE
## ww.P TRUE TRUE TRUE    FALSE    FALSE     TRUE TRUE TRUE
## nn.P TRUE TRUE TRUE    FALSE    FALSE     TRUE TRUE TRUE
## pn.P TRUE TRUE TRUE    FALSE    FALSE     TRUE TRUE TRUE
## The model object carries this many attributes
## Attributes: 
##  [1] "dim"        "dimnames"   "all.par"    "p.vector"   "par.names"  "type"       "factors"
##  [8] "responses"  "constants"  "posdrift"   "n1.order"   "match.cell" "match.map"  "is.r1"
## [15] "class"


print(model, p.vector)
## The following is how ggdmc allocates the parameters to each accumulator.
## [1] "ww.W"
##      A   b  t0 mean_v sd_v st0
## 1 1.25 1.5 0.2    2.5    1   0
## 2 1.25 1.5 0.2    1.5    1   0
## 3 1.25 1.5 0.2    1.2    1   0
## [1] "nn.W"
##      A   b  t0 mean_v sd_v st0
## 1 1.25 1.5 0.2    2.5    1   0
## 2 1.25 1.5 0.2    1.5    1   0
## 3 1.25 1.5 0.2    1.2    1   0
## [1] "pn.W"
##      A   b  t0 mean_v sd_v st0
## 1 1.25 1.5 0.2    2.5    1   0
## 2 1.25 1.5 0.2    1.5    1   0
## 3 1.25 1.5 0.2    1.2    1   0
...

## To see what other option in the simulate function
## ?ggdmc:::simulate.model
nsim <- 2048
dat <- simulate(model, nsim = nsim, ps = p.vector)
```


We used data.table to help inspect the data frame.  This makes no difference when
the data set is small. You are welcome to opt for dplyr/tibble or traditional
data.frame functions.

```
d <- data.table(dat)
dmi <- BuildDMI(dat, model)

## Check the factor levels
sapply(d[, .(S,R)], levels)
##     S    R  
## [1,] "ww" "W"
## [2,] "nn" "N"
## [3,] "pn" "P"
```


To inspect the data distributions, we designated three response proportions, instead
of correct vs. error.

```
ww1 <- d[S == "ww" & R == "W" & RT <= 10, "RT"]
ww1 <- d[S == "ww" & R == "W" & RT <= 10, "RT"]
ww2 <- d[S == "ww" & R == "N" & RT <= 10, "RT"]
ww3 <- d[S == "ww" & R == "P" & RT <= 10, "RT"]
nn1 <- d[S == "nn" & R == "W" & RT <= 10, "RT"]
nn2 <- d[S == "nn" & R == "N" & RT <= 10, "RT"]
nn3 <- d[S == "nn" & R == "P" & RT <= 10, "RT"]
pn1 <- d[S == "pn" & R == "W" & RT <= 10, "RT"]
pn2 <- d[S == "pn" & R == "N" & RT <= 10, "RT"]
pn3 <- d[S == "pn" & R == "P" & RT <= 10, "RT"]

xlim <- c(0, 5)
par(mfrow=c(1, 3), mar = c(4, 4, 0.82, 1))
hist(ww1$RT, breaks = "fd", freq = TRUE, xlim = xlim, main='Word', xlab='RT(s)',
     cex.lab=1.5)
hist(ww2$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "lightblue")
hist(ww3$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "orange")

hist(nn1$RT, breaks = "fd", freq = TRUE, xlim = xlim, main='Non-word', 
     xlab='RT(s)', ylab='', cex.lab=1.5)
hist(nn2$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "lightblue")
hist(nn3$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "orange")

hist(pn1$RT, breaks = "fd", freq = TRUE, xlim = xlim, main='P-word', 
     xlab='RT(s)', ylab='', cex.lab=1.5)
hist(pn2$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "lightblue")
hist(pn3$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "orange")
par(mfrow=c(1, 1))
```


## Prior distribution

```
p.prior <- BuildPrior(
  dists = c("tnorm", "tnorm", "beta", "tnorm", "tnorm", "tnorm"),
  p1    = c(A = .3, B = 1, t0 = 1,
            mean_v.W = 1, mean_v.N = 0, mean_v.P = .1),
  p2    = c(1, 1,   1,  3, 3, 3),
  lower = c(0, 0,   0, NA, NA, NA),
  upper = c(NA, NA, 1, NA, NA, NA))

## Visually check the prior distributions
plot(p.prior)
```



## Sampling

The default iteration is 200 for StartNewfitples function. 

```
## The default iteration is 200 for StartNewsamples function. 
fit0 <- StartNewfitples(dmi, p.prior)

## About 301 s
fit <- run(fit0)

## Diagnosis checks
gelman(fit)
# Potential scale reduction factors:
#   
#   Point est. Upper C.I.
# A              1.55       1.80
# B              1.71       2.01
# t0             1.80       2.24
# mean_v.W       1.57       1.82
# mean_v.N       1.47       1.69
# mean_v.P       1.41       1.60
# 
# Multivariate psrf
# 
# 1.98
```

The PSRF suggests that the chains have yet converged to a stable parameter space.

```
plot(fit)
```

The trace plot of posterior log-likelihood suggests the chains almost approach the parameter
space, so we discard all previous fitples as burn-in. That is, we did not turn on the _add_
switch. The fitpler reaches the parameter space fast.  It took about
700 iterations. Note this is a model with 6 parameters and some of them 
(A and B) are correlated. 

We ran another 500 (default) iterations and took a fitple every 8 iteration.
space, so we discard all previous samples as burn-in. That is, we did not turn on the _add_
switch. The sampler reaches the parameter space fast.  It took about
700 iterations. Note this is a model with 6 parameters and some of them 
(A and B) are correlated. 

We ran another 500 (default) iterations and took a sample every 8 iteration.

```
## ?run to see add and other options in run function
## Watch out! This would take a while (~ 1 hr or more depending on your CPU)
fit <- run(fit, thin=8)

## The three follow-up checks show the chains are converged and we have drawn
## sufficient size of samples.
plot(fit)

es <- effectiveSize(fit)
## A        B       t0 mean_v.W mean_v.N mean_v.P 
## 3032.669 3160.306 3264.266 2998.928 2979.326 3022.245 

gelman(fit)
# Potential scale reduction factors:
#   
#   Point est. Upper C.I.
# A                 1       1.00
# B                 1       1.00
# t0                1       1.01
# mean_v.W          1       1.00
# mean_v.N          1       1.00
# mean_v.P          1       1.00
# 
# Multivariate psrf
# 
# 1

est <- summary(fit, ps = p.vector, verbose = TRUE, recovery = TRUE)
#                   A    B mean_v.N mean_v.P mean_v.W   t0
# True           1.25 0.25     1.50     1.20     2.50 0.20
# 2.5% Estimate  1.19 0.23     1.46     1.15     2.39 0.19
# 50% Estimate   1.31 0.26     1.64     1.33     2.59 0.20
# 97.5% Estimate 1.45 0.30     1.83     1.52     2.80 0.21
# Median-True    0.06 0.01     0.14     0.13     0.09 0.00

```


The posterior prediction check takes up a lot of manually coding work. Anyway,
the figure show the data and posterior predictions are consistent, confirming
the model can successfully recover the data (at least in an ideal simulation
scenario).

```
pp <- predict_one(fit, xlim = c(0, 5))

original_data <- fit1$data
dplyr::tbl_df(original_data)
d <- data.table(original_data)

## Response proportions
d[, .N, .(S)]
d[, .N/100, .(S, R)]


## Score for the correct and error response
dat$C <- ifelse(dat$S == "ww" & dat$R == "W", "O",
         ifelse(dat$S == "nn" & dat$R == "N", "O",
         ifelse(dat$S == "pn" & dat$R == "P", "O",
         ifelse(dat$S == "ww" & dat$R == "N", "X",
         ifelse(dat$S == "ww" & dat$R == "P", "X",
         ifelse(dat$S == "nn" & dat$R == "W", "X",
         ifelse(dat$S == "nn" & dat$R == "P", "X",
         ifelse(dat$S == "pn" & dat$R == "N", "X",
         ifelse(dat$S == "pn" & dat$R == "W", "X", NA)))))))))

pp$C <- ifelse(pp$S == "ww" & pp$R == "W", "O",
        ifelse(pp$S == "nn" & pp$R == "N", "O",
        ifelse(pp$S == "pn" & pp$R == "P", "O",
        ifelse(pp$S == "ww" & pp$R == "N", "X",
        ifelse(pp$S == "ww" & pp$R == "P", "X",
        ifelse(pp$S == "nn" & pp$R == "W", "X",
        ifelse(pp$S == "nn" & pp$R == "P", "X",
        ifelse(pp$S == "pn" & pp$R == "N", "X",
        ifelse(pp$S == "pn" & pp$R == "W", "X", NA)))))))))


dat0 <- dat
dat0$reps <- NA
dat0$type <- "Data"
pp$reps <- factor(pp$reps)
pp$type <- "Simulation"
combined_data <- rbind(dat0, pp)

dplyr::tbl_df(combined_data)

p1 <- ggplot(combined_data, aes(RT, color = reps, size = type)) +
  geom_freqpoly(binwidth = .10) +
  scale_size_manual(values = c(1, .3)) +
  scale_color_grey(na.value = "black") +
  ylab("Count") +
  facet_grid(S ~ C) +
  theme_bw(base_size = 16) +
  theme(strip.background = element_blank(),
        legend.position="none") 

print(p1)

```

## How to fix array dimension inconsistency
If data were stored by a previous version of ggdmc or by DMC, their arraies
are arranged differently as noted [here](https://github.com/yxlin/ggdmc). The 
following is one convenient way to transpose them.

```
## First make sure they are indeed needed to be transposed
dim(fit0$theta)
dim(fit0$summed_log_prior)
dim(fit0$log_likelihoods)

## Use aperm and t to transpose arraies and matrices
fit0$theta <- aperm(fit0$theta, c(2, 1, 3))
fit0$summed_log_prior <- t(fit0$summed_log_prior)
fit0$log_likelihoods <- t(fit0$log_likelihoods)

fit$theta <- aperm(fit$theta, c(2, 1, 3))
fit$summed_log_prior <- t(fit$summed_log_prior)
fit$log_likelihoods <- t(fit$log_likelihoods)

## Attach the model class to the fitples. 
dim(sam0$theta)
dim(sam0$summed_log_prior)
dim(sam0$log_likelihoods)

## Use aperm and t to transpose arraies and matrices
sam0$theta <- aperm(sam0$theta, c(2, 1, 3))
sam0$summed_log_prior <- t(sam0$summed_log_prior)
sam0$log_likelihoods <- t(sam0$log_likelihoods)

sam$theta <- aperm(sam$theta, c(2, 1, 3))
sam$summed_log_prior <- t(sam$summed_log_prior)
sam$log_likelihoods <- t(sam$log_likelihoods)

## Attach the model class to the samples. 
class(fit0) <- c("list", "model")
class(fit) <- c("list", "model")

```
