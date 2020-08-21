---
title: Least Square Method
category: Modelling Basics
order: 5
---

This is a short note for one method to conduct least square minimization, using R,
to fit a diffusion process model. 

The aim of least square minimization is to minimize a cost function, which
usually calculates the difference between data and model predictions.

One way to code a stand-alone C++ progrmme for a 1-D diffusion process model 
is to directly describe such process in C++ language and compile it using
Rcpp and RcppArmadillo API. Here I assumed a within-trial constant (mean) 
drift rate as a typical case of diffusion process.

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
	 the non-decision time, "t", and the within-trial standard 
	 deviation for the drift rate, s
	 
	 "tmax" is the maximum assumed time that the diffusion 
	 process is possible to go. This is also part of the assumptions
	 "h" is the unit time of the accumulation step. 
	 
	 In summary, P[0] = v; P[1] = a; P[2] = zr; P[3] = t0; P[4] = s;
  */
  if (h <= 0)   Rcpp::stop("h must be greater than 0.");
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
    out(1) = 0; // choice corresponding to upper bound
  } else {
    out(1) = 1; // choice corresponding to lower bound
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
a parameter vector and considered it as a true parameter 
vector to simulate a diffusion process. Here, I also assumed 
a 2 second upper bound for the diffusion process and a 1-ms time step.

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

An instance of a typical 1-D diffusion process might look like the following 
figure. 

![1D-DDM]({{"/images/basics/one-diffusion.png" | relative_url}})

Usually, the instance represents or, said, simulates the unobservable cognitve 
process that happened when one responded to a test trial, which records
a pair of observable response time (RT) and response choice (0 or 1 in a binary 
choice task). In many cogntive tasks, a participant response would result in a
binary outcome, either correct or incorrect. For example a two-choice lexical 
decision task, one would respond  "word" or "non-word" to a stimuls, which 
could be real word (W) or a pesudo-word (NW).  The outcome will then be a 
correct or an incorrect response.

Table 1. A binary-choice stimulus-response table.

|           | W   | NW | 
|-----------|-----|----|
|  word     | O   | X  | 
|  non-wrod | X   | O  | 

The diffusion process model is to simulate which choice is made. The outcome in a 
trial is determined by whether the choice results in a correct or incorrect response.

## Objective Function
Like many optimization routine, I set up an objective function for least 
square minimzation. The aim of designing the objective function is to get the difference
of the predictions and the data. As typical been down in literature, I compare the 
.1, .3, .5, .7 and .9 percentils between the data and the prediction.


```
sq_diff <- c( (pred_q0 - data_q0)^2, (pred_q1 - data_q1)^2) 
```

The objective function first simulated 10,000 diffusion processes (as for 10,000 trials)
based on the parameters, received from the optimization routine. In this demonstration,
I searched for the drift rate only, so the _par_ argument is a one-elemnt vector.
Next, the objective function simply used a for loop to conduct 10,000 diffusion 
process and saved the resultant RTs and responses. Then, the function separated the 
choice-0 and choice-1 RTs for the data and for the predictions, before comparing their
five percentiles. Finally, the sum of the differences was then sent back to the
optimization routine.

```
pred_c0 <- pred_RT[pred_R==0]
pred_c1 <- pred_RT[pred_R==1]
RT_c0 <- data[data$R==0, "RT"]
RT_c1 <- data[data$R==1, "RT"]
pred_q0 <- quantile(pred_c0, probs = seq(.1, .9, .2))
pred_q1 <- quantile(pred_c1, probs = seq(.1, .9, .2))
data_q0 <- quantile(RT_c0, probs = seq(.1, .9, .2))
data_q1 <- quantile(RT_c1, probs = seq(.1, .9, .2))

## One could also use RMSE as the cost function
sq_diff <- c( (pred_q0 - data_q0)^2, (pred_q1 - data_q1)^2) 
out <- sum(sq_diff)
```

The complete objective function is listed in the following code chunk.

```
objective_fun <- function(par, data, tmax, h) {
  n <- 1e4
  pvec <- c(par[1], 1, .5, 0, 1)
  
  pred_RT <- pred_R <- numeric(n)
  
  for(i in 1:n)
  {
    tmp <- r1d(pvec, tmax, h)
    if (tmp$out[2] == 2) 
    {
      pred_RT[i] <- NA
      pred_R[i]  <- NA
      cat("fail to reach either threshold\n")
    }
    pred_RT[i] <- tmp$out[1]
    pred_R[i]  <- tmp$out[2] ## 0=upper; 1=lower
  }
  
  if ( any( is.na(pred_RT) ) || any( is.na(pred_R) ) )
  {
    out <- NA
  } else 
  {
    pred_c0 <- pred_RT[pred_R==0]
    pred_c1 <- pred_RT[pred_R==1]
    RT_c0 <- data[data$R==0, "RT"]
    RT_c1 <- data[data$R==1, "RT"]
    pred_q0 <- quantile(pred_c0, probs = seq(.1, .9, .2))
    pred_q1 <- quantile(pred_c1, probs = seq(.1, .9, .2))
    data_q0 <- quantile(RT_c0, probs = seq(.1, .9, .2))
    data_q1 <- quantile(RT_c1, probs = seq(.1, .9, .2))
	
    ## One could also use RMSE as the cost function
    sq_diff <- c( (pred_q0 - data_q0)^2, (pred_q1 - data_q1)^2) 
    out <- sum(sq_diff)
  }
  return(out)
}
```

I used the optim routine in R to search the parameters and moreover, to 
make the estimation easily, I constrain the range of estimation to -5 yo 5,
by using the method of L-BFGS-B to perform optimization. 

```
fit <- optim(par = runif(1), fn = objective_fun, tmax=tmax, h = h, 
             data = sim, method = "L-BFGS-B", lower = rep(-5, 1),
             upper = rep(5, 1))
```

To gauge the variability of the parameter estimation, I used a simple 
resampling method, via the parallel routine, mclapply, to conduct 36 
parameter studies. 

```
doit <- function(p.vector, n, tmax, h)
{
  ## Simulation some data
  RT <- R <- numeric(n)
  for(i in 1:n)
  {
    # res <- ggdmc::r1d(P=p.vector, tmax = 2, h = 1e-4)
    res <- r1d(P=p.vector, tmax=tmax, h = h)
    if(res$out[2] == 2) 
    {
      cat("fail to reach either threshold at ", i, " \n")
      RT[i] <- NA
      R[i]  <- NA
    }
    
    RT[i] <- res$out[1]
    R[i]  <- res$out[2]
  }
  ## 0 == upper
  ## 1 == lower
  ## The aim is to recover the parameters used to get the sim data set
  sim <- data.frame(s=1:n, RT=RT, R=R)
  sim <- sim[sim$R!=2, ]
  
  ## If optim can recover the presumed true parameters?
  fit <- optim(par = runif(1), fn = objective_fun, tmax=tmax, h = h, 
               data = sim, method = "L-BFGS-B", lower = rep(-5, 1),
               upper = rep(5, 1))
  return(fit)
}

## The true parameters sent to doit function
## a, zr, t0 and s were fixed in the objective function.
p.vector <- c(v=1.2, a=1, zr=.5, t0=0, s=1)
## The simulated data set has 100 trials only.
n <- 1e2

## Fixed tmax and h at 2 and 1e-4
tmax <- 2
h <- 1e-4

ncore <- 6
parameters <- parallel::mclapply(1:36, 
    function(i) try(doit(p.vector, n, tmax, h), TRUE),
    mc.cores = getOption("mc.cores", ncore))

```
![1D-DDM-Est]({{"/images/basics/one-D-result.png" | relative_url}})
