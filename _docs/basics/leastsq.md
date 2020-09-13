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
a standard model (e.g., ex-Wald) where one can find the analytic likelihood 
function, is to retain some flexibilities for later tweaking the process. This 
strategy might be useful when one wants to test a number of differernt variants 
of the process. For instance, one might want to test a hypothesis that because
participants might pay more attention to a centre region of a stimulus,
their drift rate at the centre region is faster than the drift rates at 
the other regions. This might be achieved by assigning a larger mean drift rate
to the centre, relative to the mean drift rates at the other regions. Another 
possible hypothetical variant is that one might
want to assume within a trial, the drift rate is a function of time. This 
can also achieve by tweaking the process model, for example sampling a 
moment-to-moment drift rate from a Gaussian distribution in every time step 
in a process. Nevertheless, one must note that the more elements one adds
to a process model that deviates from the standard process, the more likely that 
the altered process becomes difficult to fit (as well as prone to overfit the data).

Only a handful of process models, for example the full drift-diffusion model (DDM; 
see e.g., the Appendix in Van Zandt, 2000 for its PDF and CDF), have derived 
their analytic likelihood functions. After one tweaks a process, one must 
derive its new probability density function (PDF; sometimes as well as CDF) based on 
the altered new process (see, e.g., equation (5) in Bogacz et al., 2006 for the 
standard stochastic process equation of the DDM). One advantage of deriving 
the analytic solition for a process model, a challenging job indeed, is that one can 
then use the powerful maximum likelihood method to conduct model fitting.

The LSM, used often in machine learning, is an alternative method of conducting model
fitting, without the necessarity to derive the likelihood function.

The following code snippet is a stand-alone C++ progrmme for a 1-D diffusion (process)
model. I assumed a within-trial constant (mean) drift rate as in a typical case of 
diffusion process.

See code comments to get further details.

```
#include <RcppArmadillo.h>
using namespace Rcpp;

// [[Rcpp::depends(RcppArmadillo)]]

// [[Rcpp::export]]
Rcpp::List r1d(arma::vec P, double tmax, double h)
{
  /* P is a parameter vector, with the drift rate, "v", 
     the upper boundary, "a", the relative starting point, "zr", 
	 the non-decision time, "t0", and the within-trial standard 
	 deviation for the drift rate, s.
	 
     The lower boundary is at 0, because the starting point, z, 
	 has been converted to be relative (ie zr). 
	 
	 "tmax" is the maximum assumed time that the diffusion 
	 process is possible to go. 
	 
	 "h" is the unit time of the accumulation step. 
	 
	 In summary, P[0] = v; P[1] = a; P[2] = zr; P[3] = t0; P[4] = s;
  */
  
  if (h <= 0)      Rcpp::stop("h must be greater than 0.");
  if (tmax <= 0)   Rcpp::stop("tmax must be greater than 0.");
  if (P[2] > P[1]) Rcpp::stop("z > a");
  if (P[3] < 0)    Rcpp::stop("t0 > 0");
  if (tmax < 1 )   Rcpp::Rcout << "tmax less than 1.\n";
  
  arma::vec T, sigma_wt, mut, out(2);
  double current_evidence;
  
  T = arma::regspace(0, h, tmax);   // h must > 0
  unsigned int nmax=T.n_elem, i=1;  // if tmax = 2, nmc = 20001
  
  // the unit travelling distance 
  mut = h * P[0]*arma::ones<arma::vec>(nmax);
  sigma_wt = std::sqrt(h) * P[4]*arma::randn(nmax);   // the random component 
  arma::vec  Xt(nmax); Xt.fill(NA_REAL);
  
  // Starting evidence; Xt records the trace of the accumulator
  // z = a *zr
  Xt(0) = P[2] * P[1]; 
  current_evidence = Xt(0);
  
  while (current_evidence < P[1] && current_evidence > 0 && i < nmax)
  {
    Xt(i) = Xt(i-1) + mut(i) + sigma_wt(i);
    current_evidence = Xt(i);
    i++;
  }
  
  out(0) = i * h + P[3]; // DT + t0 = RT
  if (i == nmax) {
    out(1) = 2; // fail to reach threshold
  } else if (current_evidence > P[1]) {
    out(1) = 1; // choice corresponding to upper bound
  } else {
    out(1) = 0; // choice corresponding to lower bound
  }
  
  // The function return (1) the time vector; (2) the bivariate responses, 
  // choice and RT; and (3) the evidence trace, Xt
  return Rcpp::List::create(Rcpp::Named("T")  = T,
                            Rcpp::Named("out")= out,
                            Rcpp::Named("Xt") = Xt);
}
```

## Simulate a Diffusion Process
To inspect an instance of a diffusion process, I designated
a parameter vector and considered it as a "true" parameter vector.

This is just to do the simulation. In normal model fitting, one would 
not know the values of "true" parameters. One aim of fitting 
a model is to find a set optimal parameters that accounts the 
data.

I assumed a two-second time span for the diffusion process 
and used a 1-ms time step. 


```
p.vector <- c(v=1.2, a=1, zr=.5, t0=.05, s=1)
res <- r1d(P=p.vector, tmax = 2, h = 1e-4)

## To locate the first instance of NA
idx <- sum(!is.na(res$Xt)); idx
z <- p.vector[2] * p.vector[3]; z  ## zr * a = z

plot(res$T[1:idx], res$Xt[1:idx], type='l', ylim=c(0, 1), xlab='DT (s)',
     ylab='Evidence')
abline(h=1, lty='dotted', lwd=1.5)
abline(h=0, lty='dotted', lwd=1.5)
points(x=0, y=z, col='red', cex =2)
```

![1D-DDM]({{"/images/basics/one-diffusion.png" | relative_url}})

Usually, the instance represents or, said simulates, an unobservable cognitve
process that happens when one responds to a trial. For example, in a driving
simulator study for an automatic vehicle, in a trial, a participant may sit in 
the driver seat, engage in other tasks. When, for example, simulated fog is 
unveiled, the participant suddenly is able to see the front view and perhaps
notice another vehcile is in the front. 

The visual stimuli, the front vehicle, its surronding scene, as well as the 
participant's own kinetmatic sense of her vehicle (speed, accelaration etc), 
her psychological assessment of the distance between her AV and the vehicle 
in the front, all composes of (more precisely are assumed to be) the stimuli 
resulting in some "sensory evidence" in the particpant's cognition.

These, namely the "sensory evidence", are the inputs.

In a 2AFC diffusion model, the outputs usually are a pair of numbers. The 
most well-known is the response time (RT) and the other is response choice.
The latter can be represented as 0 and 1 in the binary choice task. The outputs
are usually more easily to observe in a typical, standard psychological task.
The inputs, however, are not.


## Responses, Choices, and Accuracy
In a typical psychological task, a participant responds usually by entering 
a response via a computer keyboard, for example, "z" for option 1, and "/" for 
option 2. The action of a response is usually recorded, namely either "z" or
"/", for every trial. The researcher can then later know which option a 
participant has chosen in a trial. 

One must note that a participant may decide to indicate she thinks a 
stimulus belongs to option 1, but in reality, the stimulus could belong to
option 2. This is an outcome of mismatch. This brings us to the idea of matching 
responses to stimuli.

In other words, a response, in a binary task, could result in two
different outcomes, correct or incorrect. For example in a two-choice lexical 
decision task, one would respond  "word" or "non-word" to a stimuls, which 
could be real word (W) or a pesudo-word (NW). 

Only after a response is committed is the outcome becomes apparent

Table 1. A binary-choice stimulus-response table.

|           | W   | NW | 
|-----------|-----|----|
|  word     | O   | X  | 
|  non-wrod | X   | O  | 


## Objective Function
In the following, I demonstrated a simple method to fit a two-choice
diffusion model, using the LSM.  First, I set up an objective function. The 
aim of designing the objective function is to get the difference of the 
predictions and the data. As typically been down in the literature 
applying diffusion models, I compare the five percentils, .1, .3, .5, .7 and 
.9 between the data and the prediction.

The following code snippet showed specifically this calculation.

```
sq_diff <- c( (pred_q0 - data_q0)^2, (pred_q1 - data_q1)^2) 
```

To make the demonstration simple, I aimed only to recover the drift rate and 
fixed the other parameters (_a_, _zr_, _t0_, and _s_). I wrote another stand-alone C++ 
function, which simply used a for-loop wrap around the above r1d function and added
a few checks on the data quality. I named this function, "rdiffusion".

Next, the objective function took the drift rate parameter from the optimization 
routine and put it at the first position of the "pvec" object.  I fixed the second
to fifth parameters by manually entering their values. The objective function then 
simulated "nsim" number of diffusion processes. I passed 10,000 to the nsim at
this line.


```
nsim <- 1e4
```

Then, I removed the problematic trials, storing their indices into the "bad" object. 
I designated NA to those process suppassing the assumed upper time limit (i.e., tmax).
I also designated 0 and 1, respectively  to the procoesses that result in hitting lower
and upper boundaries. Thus, the line with, "pred_R == 1", was to extract the 
indices for the simulated trials that hit the upper boundary. 

The line, "upper_count <- sum(upper)" was to count how many simulated trials result
in choice 1 (i.e., htting upper boundary). This was to gauge the wild guesses at the early
stage of optimzation.  The optimization routine may cast strange drift rates,
resulting in the process that produces no responses (i.e., outside the parameter space,
under by my assumptions).


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
make the estimation relaively easy, I limited the range of estimation to 0 to 5.
The _optimize_ is for search one dimension space. See ?optimize for further
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


The following is the code snippet.

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


![1D-DDM-Est]({{"/images/basics/one-D-result.png" | relative_url}})
