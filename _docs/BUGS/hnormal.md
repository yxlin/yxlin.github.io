---
title: Hierarchical Noraml Model
category: BUGS Examples Volumn 1
order: 1
---

Disclaimer: This tutorial uses an experimental (beta) version of _ggdmc_, which has 
added the functionality of fitting regression models.  The software 
can be found in its GitHub.

The aim of tutorial is to docuemnt one method to fit a hierarchical 
normal model, using the Rats example in the BUGS examples volumn I. This expands
the scope of ggdmc, not only to fit cognitive models but also to fit standard
regression models. 

## Set-up Model
The DDM composes of two complementary defective distribtions; thereby,
two response types. Unlike the DDM, a regression model has only one response type;
thereffby one (complete) distribution. Therefore, the _match.map_ and _responses_
arguments are set as _NULL_ and _"r1"_ (meaning only one response type). 

The argument _regressors_ enters the independent / predictive
variable (typically denoted X).  In the Rats example, the weights of thirty
young rats were measured weekly for five weeks and the measurements taken at the
end of each week (8th, 15th, 22rd, 29th, & 36th day) were provided. The
parameterization is _a_ (intercept), _b_ (slope) and the precision ($$ = 1/sd^2$$).


```
require(ggdmc)
model <- BuildModel(
    p.map      = list(a = "1", b = "1", tau = "1"),
    match.map  = NULL,
    regressors = c(8, 15, 22, 29, 36), 
    factors    = list(S = c("x1")),
    responses  = "r1",
    constants  = NULL,
    type       = "glm")
## Parameter vector names are: ( see attr(,"p.vector") )
## [1] "a"   "b"   "tau"
## 
## Constants are (see attr(,"constants") ):
## NULL
## 
## Model type = glm

```

## Recovery Study
Next, I took values from the Rats example as the true parameters at
the population level and used them to simulate an ideal data set, 
which has 1000 rats and each of them contributes 100 response.
_tnorm2_ is truncated normal distribution, using mean and precision
parametrization. When both the upper and lower are set NA, the tnorm
become normal distribution.

```
  npar <- length(GetPNames(model))
  pop.mean <- c(a = 242.7, b = 6.189, tau = .03)
  pop.scale <- c(a = .005, b = 3.879, tau = .04)
  ntrial <- 100
  pop.prior  <-BuildPrior(
    dists = rep("tnorm2", npar),
    p1    = pop.mean,
    p2    = pop.scale,
    lower = c(NA, 0, 0),
    upper = rep(NA, npar))
  dat <- simulate(model, nsub = 1000, nsim = ntrial, prior = pop.prior)
  dmi <- BuildDMI(dat, model)
  ps <- attr(dat, "parameters") ## Extract true parameters for each individual

  plot(pop.prior, ps = pop.mean)

```

![pop_prior]({{"/images/BUGS/pop_prior.png" | relative_url}})


### Set up Priors
To randomly draw initial values for the data- and hyper-level parameters,
I set up three sets of distributions and bind them as a list, named _start_. 

```
  pstart <- BuildPrior(
    dists = c("tnorm", "tnorm", "tnorm"),
    p1    = c(a = 242,  b = 6.19, tau = .027),
    p2    = c(a = 14, b = .49, tau = 10),
    lower = c(NA, NA, 0),
    upper = rep(NA, npar))
  lstart <- BuildPrior(
    dists = c("tnorm", "tnorm", "tnorm"),
    p1    = c(a = 200,  b = 5, tau = .01),
    p2    = c(a = 50, b = 1, tau = .01),
    lower = c(NA, NA, 0),
    upper = rep(NA, npar))
  sstart <- BuildPrior(
    dists = c("tnorm", "tnorm", "tnorm"),
    p1    = c(a = 10,  b = .5, tau = .01),
    p2    = c(a = 5, b = .1, tau = .01),
    lower = c(NA, NA, 0),
    upper = rep(NA, npar))
  start <- list(pstart, lstart, sstart)

  p.prior  <- BuildPrior(
    dists = rep("tnorm2", npar),
    p1    = c(a = NA, b = NA, tau = NA), 
    p2    = rep(NA, 3),
    lower = c(NA, 0, 0),
    upper = rep(NA, npar))
  mu.prior  <- BuildPrior(
    dists = rep("tnorm2", npar),
    p1    = c(a = 200, b = 6, tau = 3)
	p2    = c(a = 1e-4, b = 1e-3, tau = 1e-2)
    lower = c(NA, 0, 0),
    upper = rep(NA, npar))
  sigma.prior <- BuildPrior(
    dists = rep("gamma", npar),
    p1    = c(a = .01, b = .01, tau = .01),
    p2    = c(a = 1000,  b = 1000, tau = 1000),
    lower = c(0, 0, 0),
    upper = rep(NA, npar))
  prior <- list(p.prior, mu.prior, sigma.prior)

```

![pop_prior]({{"/images/BUGS/model.png" | relative_url}})

## Sampling
The function, _StartNewhiersamples_ use the _start_ priors
only for drawing initial values. The _prior_ distributions wil
be used in the model fit.

```
fit0 <- run(StartNewhiersamples(5e2, dmi, start, prior))
fit  <- run(RestartHypersamples(5e2, fit, thin = 32))

```

## Model Diagnosis
As usually, I check the potential scale reduction factors (Brook & Gelman,1998). All
are less than 1.05, suggesting all chains are well mixed.

```
rhat <- hgelman(fit, verbose = TRUE)

```

Then, I calculated effective samples at the hyper parameters, for one participant at
the parameter of the data level, and similarly for all participants. This is to 
check if enough posterior samples are drawn. 

```
hes <- effectiveSize(hsam, hyper = TRUE)
es1 <- effectiveSize(hsam[[1]])

##    a.h1     b.h1   tau.h1     a.h2     b.h2   tau.h2 
## 427.9587 767.7925 483.1228 613.3212 730.1198 462.4242 

##        a        b      tau 
## 569.3685 609.0303 572.1573 

  p0 <- plot(fit, hyper = TRUE)
  p1 <- plot(fit, hyper = TRUE, pll = FALSE, den = TRUE)
  
```

![traceplot]({{"/images/BUGS/traceplot1.png" | relative_url}})
![density-hyper]({{"/images/BUGS/densityplot1.png" | relative_url}})



```
est1 <- summary(fit, hyper = TRUE, recover = TRUE, start = 101,
                ps = pop.mean,  type = 1, verbose = TRUE, digits = 3)
est2 <- summary(fit, hyper = TRUE, recover = TRUE, start = 101,
                ps = pop.scale, type = 2, verbose = TRUE, digits = 3)
est3 <- summary(fit, recover = TRUE, ps = ps, verbose = TRUE)
				  
##                     a      b   tau
## True           242.700  6.189 0.030
## 2.5% Estimate  241.456  6.143 0.008
## 50% Estimate   242.275  6.173 0.460
## 97.5% Estimate 243.081  6.206 1.338
## Median-True     -0.425 -0.016 0.430
## 
##                    a      b   tau
## True           0.005  3.879 0.040
## 2.5% Estimate  0.005  3.533 0.042
## 50% Estimate   0.005  3.835 0.047
## 97.5% Estimate 0.005  4.156 0.058
## Median-True    0.000 -0.044 0.007
## 
## Summary each participant separately
##           a    b   tau
## Mean 242.28 6.17  3.82
## True 242.29 6.17  3.81
## Diff   0.01 0.00 -0.01
## Sd    14.14 0.51  2.80
## True  14.13 0.51  2.91
## Diff   0.00 0.00  0.11

```

## Load Rats Data

```
tmp <- dget("data/Rats_data.R")
d <- data.frame(matrix(as.vector(tmp$Y), nrow = 30, byrow = TRUE))
names(d) <- c(8, 15, 22, 29, 36)
d$s <- factor(1:tmp$N)
long <- melt(d, id.vars = c("s"), variable.name = "xfac",
               value.name = "RT")

long$X <- as.double(as.character(long$xfac)) - tmp$xbar
long$S <- factor("x1")
long$R <- factor("r1")
d <- long[, c("s", "S", "R", "X", "RT")]

## Each rat contribute 5 trials / observations
DT <- data.table(d)
DT[, .N, .(s)]
##      s N
##  1:  1 5
##  2:  2 5
##  3:  3 5
##  ...
## 30: 30 5


## Bind data and model together
dmi <- BuildDMI(d, model)
## Sampling
fit0 <- run(StartNewhiersamples(500, dmi, start, prior))
fit <- run(RestartHypersamples(5e2, fit0, thin = 32))

est1 <- summary(fit, hyper = TRUE, type = 1, verbose = TRUE, digits = 3)
##                      a      b   tau
## 2.5% Estimate  237.269  5.974 0.012
## 50% Estimate   242.335  6.175 0.042
## 97.5% Estimate 247.480  6.379 0.056
## Median-True     -0.365 -0.014 0.012
est2 <- summary(fit, hyper = TRUE, type = 2, verbose = TRUE, digits = 3)
##                    a      b      tau
## 2.5% Estimate  0.003  2.038  372.245
## 50% Estimate   0.005  3.798 1240.848
## 97.5% Estimate 0.008  6.607 3058.090
## Median-True    0.000 -0.081 1240.808

hes <- effectiveSize(fit, hyper = TRUE)
##     a.h1     b.h1   tau.h1     a.h2     b.h2   tau.h2 
## 4500.000 4534.287 4193.927 3807.489 4079.768 3139.033
   
round(apply(data.frame(es), 1, mean))
round(apply(data.frame(es), 1, sd))
round(apply(data.frame(es), 1, max))
round(apply(data.frame(es), 1, min))
##         a    b  tau 
## Mean 4464 4360 4321 
## SD    139  242  348 
## MAX  4717 5020 5137 
## MIN  4100 3732 3455 
  
```
  
![traceplot_rat]({{"/images/BUGS/traceplot_rats.png" | relative_url}})
![density_rat]({{"/images/BUGS/densityplot_rats.png" | relative_url}})
