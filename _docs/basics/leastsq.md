---
title: Least Square Method
category: Modelling Basics
order: 5
---

This is a short note for doing least square minimization to fit a diffusion
process model.

The aim of the least square minimization (LSM) is to minimize a cost function,
which returns the difference between the data and model predictions.

One possible reason to fit data to a process model, instead of 
a standard model [e.g., ex-Wald, (Schwarz, 2001; Schwarz, 2002; Heathcote, 2004)] 
where one can find the analytic likelihood 
function, is to retain some flexibilities for later tweaking the process. This 
strategy might be useful when one wants to test a number of differernt variants 
of the process. For instance, one might want to test a hypothesis that because
participants might pay more attention to a centre region of a stimulus,
their drift rate at the centre region is faster than the drift rates at 
the other regions. This might be achieved by assigning a larger mean drift rate
to the centre, comparing with assigning smaller mean drift rates to other 
regions. Another possible hypothetical variant is that one might
want to assume within a trial, participants change their drift rate 
significantly. This can be tested by tweaking the standrd diffusion process, 
such as, constructing a series of different Gaussian models, which are used 
to sample different drift rates at different time point in a process. Nevertheless, 
one must note that the more elements one adds
to a process model that deviates from the standard process, the more likely that 
the altered process becomes difficult to fit (as well as prone to overfit the data).

Only a handful of process models, for example the full drift-diffusion model (DDM; 
see e.g., the Appendix in Van Zandt, 2000 for its PDF and CDF), have derived 
their analytic likelihood functions. After one tweaks a standard process, if one 
wants to apply model fitting methods involving likelihood functions, one must also 
derive the new probability density function (PDF; sometimes as well as CDF) based on 
the altered new process (see the video provided by StatQuesta for a brief and 
excellent explantion regarding the probability and the likelihood at 
https://www.youtube.com/watch?v=pYxNSUDSFH4). (see, also e.g., equation (5) in 
Bogacz et al., 2006 for the standard stochastic process equation of the DDM). 

One advantage of deriving the analytic solution for a process model (a 
challenging job indeed) is that one can use the powerful maximum likelihood method 
to conduct model fitting. 

The LSM, often used in machine learning, is an alternative method for model
fitting, without using the likelihood function.

The following code snippet is an R progrmme for a 1-D diffusion (process)
model. The R code snippet is perhaps easier for readers to understand and 
to implement themselves. The real working programe is written in C++.

I assumed a within-trial constant (mean) drift rate as in a typical case of 
diffusion process.  See code comments to get further details.

```
r1d_R <- function(pvec, tmax, h)
{
  Tvec <- seq(0, tmax, h)
  nmax <- length(Tvec)
  
  ## Unit travelling distance; ie how far a particle travels per unit time 
  ## 1. Here we used h (usually set to 1 ms) as the unit time
  ## 2. In the constant-drift model, the drift rate does not change within
  ## a process, although it is subjected to the influence of within-trial 
  ## variability. That is, the "constant" refers to the mean drift rate is
  ## constant.
  ## 3. travel distance = drift rate * unit time 
  ## the 1 vector ( ie rep(1, nmax) ) is to make "mut" a vector. This
  ## pre-calculation help to reduce computation time.
  mut <- h * pvec[1] * rep(1, nmax)
  
  ## Within-trial standard deviation, assuming standard normal noise 
  ## (mu = 0, sd = 1) 
  sigma_wt <- sqrt(h) * pvec[5] * rnorm(nmax) 
  
  ## Evidence value store; Xt records the trace of the particle 
  Xt <- rep(NA, nmax)
  
  ## The first value of the evidnece is the assumed starting point
  ## pvec[3] expects the user enters the relative starting point, zr
  Xt[1] <- pvec[3] * pvec[2]  ## convert zr to z, assuming symmetric
  current_evidence <- Xt[1];  ## transient storage for the current evidence
  
  ## Start the evidence accumulation process
  ## Note 1. We did not know when the process would stop beforehand
  ## Note 2. We assumed the studied process cannot exceed nmax * h seconds
  ## Note 3. Only when the latest evidence value exceeds the threshold value,
  ##         the process stops.
  i <- 2
  
  ## pvec[2] is the upper bound; 0 is the lower bound.
  while (current_evidence < pvec[2] && current_evidence > 0 && i < nmax)
  {
    ## This is the typical diffusion process equation
    ## the updated evidence value = the latest evidence value + 
    ##    (drift rate * unit time) + within-trial standard deviation 
    Xt[i] <- Xt[i-1] + mut[i] + sigma_wt[i] 
    current_evidence <- Xt[i];  ## Store the updatd evidence value for while check
    i <- i + 1;  ## increment step 
  }
  
  ## cat("i nmax, current_evidence", i, " ", nmax, " ", current_evidence, "\n")
  RT <- i * h + pvec[4];     ## decision time + t0 = response time 
  is_broken <- i == nmax;    ## whether the simulation suppasses the assumed max time 
  
  ## hit upper bound (1) or lower bound (0)
  R <- ifelse(current_evidence > pvec[2], 1, 0) 
  
  ## Using list to return extra information.
  ## We do not usually return Xt, Tvec and is_broken
  return(list(Xt = Xt, Tvec= Tvec, RT=RT, R = R, is_broken=is_broken))
}

```

## Simulate a Diffusion Process
To inspect an instance of a diffusion process, I designated
a parameter vector and considered it as a "true" parameter vector.

This is just to conduct the simulation. In a regular model fitting, 
one would not know the true values of the parameters. One aim of fitting 
a model to data is to find a set optimal parameters that accounts the 
data.

I assumed a two-second time span for the diffusion process 
and used a 1-ms time step. 


```
tmax <- 2
h <- 1e-3
p.vector <- c(v=0, a=1, z=.5, t0=0, s=1)
res1 <- r1d_R(pvec=p.vector, tmax=tmax, h=h)

## To locate the first instance of NA
idx <- sum(!is.na(res1$Xt)); 

z <- p.vector[2] * p.vector[3]; z  ## zr * a = z

plot(res1$Tvec[1:idx], res1$Xt[1:idx], type='l', ylim=c(0, 1), xlab='DT (s)',
     ylab='Evidence')
abline(h=1, lty='dotted', lwd=1.5)
abline(h=0, lty='dotted', lwd=1.5)
points(x=0, y=z, col='red', cex =2)
```

![1D-DDM]({{"/images/basics/one-diffusion.png" | relative_url}})

Usually, the instance represents or, said simulates, an unobservable cognitve
process that happens when one responds to a trial. For example, in a driving
simulator study for an automatic vehicle, in a trial, a participant may sit 
insider the simulator and engage in some tasks. When, for example, the 
simulated fog is unveiled, the participant suddenly is able to see the front
view and perhaps notice another vehcile is in the front. At this moment,
the participant was instructed to make a judgement to decide whether to 
take over control of the vehicle and disengage the automatic driving system.

One might assume the stimulus composes of the front vehicle, its 
surrondings, as well as the participant's own kinetmatic sense of her 
vehicle (speed, accelaration etc), her psychological assessment of the 
distance between her AV and the vehicle in the front. 

The stimulus then presumably elicits usually unobservable "sensory evidence" 
in the particpant's mind. The "sensory evidence" is the input (i.e., 
"Evidence" in the previous figure).

In a 2AFC diffusion model, the outputs usually are a pair of numbers. The 
most well-known is the response time (RT) and the other is response choice.
The latter can be represented as 0 and 1 in a binary-choice task. The outputs
are usually more easily to observe in a typical, standard psychological task.
The input, however, is not.


## Responses, Choices, and Accuracy
In a typical psychological task, a participant responds usually by entering 
her response via a computer keyboard, for example, "z" for option 1, and "/" for 
option 2. This action is usually recorded, namely either "z" or
"/", for every trial.  The researcher can then later know which option a 
participant has chosen in a trial. This is the researcher infers what a 
participant thought by asking her to report via a computer keyboard. (other 
oft-used methods have right-left mouse clicks, touching different screen 
location, attaching sensors onto participants' hands or fingers)

One must note that a participant may decide to indicate she thinks a 
stimulus belongs to option 1, but in reality, the stimulus could belong to
option 2. This is an outcome of mismatch. This brings us to the idea of matching 
responses to stimuli.

In other words, a response, in a binary task, could result in two
different outcomes, correct or incorrect. For example in a two-choice lexical 
decision task, one would respond "word" or "non-word" to a stimuls, which 
could be real word (W) or a pesudo-word (NW). 

Only after a response is committed has the outcome become apparent.

Table 1. A binary-choice stimulus-response table.

|           | W   | NW | 
|-----------|-----|----|
|  word     | O   | X  | 
|  non-wrod | X   | O  | 


## Objective Function
In the following, I showed a simple method to fit a two-choice
diffusion model, using the LSM.  First, I set up an objective function. The 
aim of designing the objective function is to get the difference of the 
predictions and the data. As typically been done in the literature 
applying diffusion models, I compared the five percentils, .1, .3, .5, .7 and 
.9. The following code snippet showed this calculation.

```
sq_diff <- c( (pred_q0 - data_q0)^2, (pred_q1 - data_q1)^2) 
```

To make the demonstration simple, I aimed only to recover the drift rate and 
fixed the other parameters (_a_, _zr_, _t0_, and _s_). I wrote another 
stand-alone C++ function, which simply used a for-loop wrap around the above 
r1d function and added a few checks on the data quality. I named this function,
"rdiffusion".

Next, the objective function took the drift rate parameter from the optimization 
routine and put it at the first position of the "pvec" object.  I fixed the second
to fifth parameters by manually entering their values. The objective function then 
simulated "nsim" number of diffusion processes. I passed 10,000 to the nsim 
object.

```
nsim <- 1e4
```

Then, I removed the problematic trials, storing their indices into the "bad" object. 
I designated NA to those process suppassing the assumed upper time limit (i.e., tmax).
I also designated 0 and 1, respectively, to the procoesses that result in hitting lower
and upper boundaries. Thus, the line with, "pred_R == 1", was to extract the 
indices for the simulated trials hitting the upper boundary. 

The line, "upper_count <- sum(upper)" was to count how many simulated trials result
in choice 1 (i.e., htting upper boundary). This was to gauge the wild parameter values 
at the early stage of optimzation. The optimization routine may cast some drift rate 
values, resulting in the process that produces no responses (i.e., outside the parameter 
space, under the assumptions).


```
    bad <- (is.na(tmp[,2])) || (tmp[,2] == 2)
    sim <- tmp[!bad, ]
    
    pred_RT <- sim[,1]
    pred_R  <- sim[,2]

    upper <- pred_R == 1
    lower <- pred_R == 0
    upper_count <- sum(upper)
    lower_count <- sum(lower)

```

Next, the objective function returns a very large number, 1e9, if the parameters 
resulting in abnormal diffusion processes. Otherwise, I separated the RTs for the choice 1 
and choice 2, respectively, for the data and for the predictions and then compared
their five percentiles. Finally, the sum of the differences was sent back to 
the optimization routine.

```
        data_RT <- data[,1]
        data_R  <- data[,2]
        d_upper <- data[,2] == 1
        d_lower <- data[,2] == 0
        RT_c0   <- data_RT[d_upper]
        RT_c1   <- data_RT[d_lower]

        pred_c0 <- pred_RT[upper]
        pred_c1 <- pred_RT[lower]
        
        pred_q0 <- quantile(pred_c0, probs = seq(.1, .9, .2))
        pred_q1 <- quantile(pred_c1, probs = seq(.1, .9, .2))
        
        data_q0 <- quantile(RT_c0, probs = seq(.1, .9, .2))
        data_q1 <- quantile(RT_c1, probs = seq(.1, .9, .2))
        sq_diff <- c( (pred_q0 - data_q0)^2, (pred_q1 - data_q1)^2)
        out <- sum(sq_diff)

```

The complete objective function is listed in the following code snippet.

```
objective_fun <- function(par, data, tmax, h, nsim) {
    pvec <- c(par[1], 1, .5, 0, 1)
    tmp <- rdiffusion(nsim, pvec, tmax, h)

    bad <- (is.na(tmp[,2])) || (tmp[,2] == 2)
    sim <- tmp[!bad, ]
    
    pred_RT <- sim[,1]
    pred_R  <- sim[,2]

    upper <- pred_R == 1
    lower <- pred_R == 0
    upper_count <- sum(upper)
    lower_count <- sum(lower)

    
    if (any(is.na(pred_R))) {
        ## return a very big value, so the algorithm throws out
        ## this parameter
        out <- 1e9   
    } else if ( is.na(sum(upper_count)) || is.na(sum(lower_count)) ) {
        ## return a very big value, so the algorithm throws out
        ## this parameter
        out <- 1e9
    } else {
        data_RT <- data[,1]
        data_R  <- data[,2]
        d_upper <- data[,2] == 1
        d_lower <- data[,2] == 0
        RT_c0   <- data_RT[d_upper]
        RT_c1   <- data_RT[d_lower]

        pred_c0 <- pred_RT[upper]
        pred_c1 <- pred_RT[lower]
        
        pred_q0 <- quantile(pred_c0, probs = seq(.1, .9, .2))
        pred_q1 <- quantile(pred_c1, probs = seq(.1, .9, .2))
        
        data_q0 <- quantile(RT_c0, probs = seq(.1, .9, .2))
        data_q1 <- quantile(RT_c1, probs = seq(.1, .9, .2))
        sq_diff <- c( (pred_q0 - data_q0)^2, (pred_q1 - data_q1)^2)
        out <- sum(sq_diff)
    }
    
  return(out)
}

```

I used the _optimize_ routine to search the parameters. To 
make the estimation simple, I limited the range of estimation to 0 to 5.
The _optimize_ is for searching one dimension space. See ?optimize for further
details. For higher dimension, one must use other optimization routines.


```
fit <- optimize(f=objective_fun, interval=c(0, 5), data = dat,
                tmax=tmax, h=h, nsim=nsim)
```

To estimate the variability, I used a simple resampling method, via the 
parallel routine, mclapply, to conduct 100 parameter-recovery studies. 

```
doit <- function(p.vector, n, tmax, h, nsim)
{
    dat <- rdiffusion(n, p.vector, tmax, h)
    fit <- optimize(f=objective_fun, interval=c(0, 5), data = dat,
                    tmax=tmax, h=h, nsim=nsim)
    return(fit)
}

```


The following is the code snippet for launching the parameter-recovery studies..

```
## Assume the "real" process has the parameters, p.vector
## The aim is to recover the drift rate , 1.51
p.vector <- c(v=1.51, a=1, zr=.5, t0=0, s=1)
tmax  <- 2
h     <- 1e-3
ncore <- 3

## Assume we have collected "real" empirical data, which has 5,000 trials
n <- 5e3

## I requested the objective function to simulate 10,000 trials to 
## construct the simulated historgram, every time the optimization routine
## make a guess about what the drift rate could be.
nsim <- 1e4

## Each parallel thread run an independent parameter-recovery study. 
## Here I ran 100 separate parameter-recovery studies.

## About 5.24 mins on a very good CPU
parameters <- parallel::mclapply(1:100, function(i) try(doit(p.vector, n, tmax, h,
                                                            nsim), TRUE),
                                 mc.cores = getOption("mc.cores", ncore))


```

## Results

The figure showed most estimated drift rates are around the true value (red line), 
with a roughly normally distributed shape.

![1D-DDM-Est]({{"/images/basics/one-D-result.png" | relative_url}})
