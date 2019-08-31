---
title: Shooting Decision Model - Recovery Study
category: Hierarchical Model
order: 4
---

Pleskac, Cesario and Johnson (2017) examined a thorny issue in U.S.A (Wong, 2016;
Chinese Community Reels After Brooklyn NYPD Shooting, 2014; American's police on trial, 2014),
whether a police officer's decision, _to shoot or not to shoot_, is
affected by the race of a shooting target and many other related factors. This is an
important question that cognitive experiments might be able to provide some insights. They
analyzed four data sets with the hierarchical Wiener diffusion model. They kindly
provide their data and JAGS codes at their project [OSF](https://osf.io/9qku5/). You may
also want to read their [article](https://doi.org/10.3758/s13423-017-1369-6), which
describes the findings. A previous study, fitting data from also a first-person-shooter
task with fixed-effect DDM, is reported in Correll, Wittenbrink, Crawford and
Sadler (2015).

In this tutorial, I used the data in Pleskac, Cesario and Johnson (2017) to demonstrate
how to use pMCMC to fit hierarchical Wiener diffusion to empirical data, although one
might account for the decision scenario more relatistically by using the
urgency-gating model (Cisek, Puskas, & El-Murr, 2009). That says, I did not argue the urgency-
gating model is better than the HDDM, as the story about the LCA model suggested
(Miletic, Turner, Forstmann, & van Maanen, 2017). Only when we put them into tests can we know
better whether the urgency-gating model is better than the HDDM to account for the shooting
decisions. 

In the case of fitting empirical data I need to rely on other techniques, for example
_posterior predective check_ (Gelman, Carlin, Stern, Dunson, Vehtari, & Rubin, 2014), to 
check whether posterior distributions appropriately reflect target distributions, because 
I do not know the true data-generation mechanism.

## Set-up a model object
First, I defined a race-threshold model,based on the stereotype findings in classic
social psychology literature (Duncan, 1976; Sagar & Schofield, 1990). One question
related to this classic observation is that whether this stereotype affects
people's decision threshold, their decision rate, or both. In the first model,I
set up a race-threshold model as model1. Below is a list of the abbreviations
for each experimental factor.

1. RACE: the stimulus shows an African American (A) or a European American (E)
2. S: the stimulus shows one holding a gun (G) or other object (N, not a gun)
3. R: response to "shoot" or "not" to shoot

Below is a list of the abbrevations of the DDM parameters.

1. a: the boundary separation
2. v: the mean of the drift rate
3. z: the mean of the starting point of the diffusion relative to threshold separation
4. d: differences in the non-decisional component between upper and lower threshold
5. sz: the width of the support of the distribution of zr
6. sv: the standard deviation of the drift rate
7. t0: the mean of the non-decisional component of the response time
8. st0: the width of the support of the distribution of t0

_a = RACE_ refers to the model assumes that the race factor affects the _a_ parameter.
In R style formula, this may look like, _a ~ RACE_.

> match.map = list(M = list(G = "shoot", N = "not")),

stands for that when a trial records a stimuls type as "G", and a response of "shoot", it
will be coded (by _BuildModel_) as correct response (TRUE), otherwise error response
(FALSE). 

> factors = list(S = c("G", "N"), RACE = c("E", "A")),

stands for that experiment has two factors, S and RACE, each of them has two levels. The
former has a _G_ level for holding a gun object, and a _N_ level for holding a
nongun object and the latter has a _E_ level for European American and and _A_
level for African American, levels.

```
library(ggdmc)
model <- BuildModel(
   p.map     = list(a = "RACE", v = "S", z = "1", d = "1", sz = "1", sv = "1",
                   t0 = "1", st0 = "1"),
   match.map = list(M = list(G = "shoot", N = "not")),
   factors   = list(S = c("G", "N"), RACE = c("E", "A")),
   constants = c(st0 = 0, d = 0),
   responses = c("shoot", "not"),
   type      = "rd")
npar <- length(GetPNames(model))

```

I conducted a parameter recovery study to certain that the model
can fit the data properly beforce I fit to the real data.

```
## Population distribution
pop.mean  <- c(a.E = 1.5, a.A = 2.5, v.G = 3,  v.N = 2, z = .5, sz = .3,
  sv = 1,  t0 = .2)
pop.scale <- c(a.E =.5, a.A = .8, v.G = .5, v.N = .5, z = .1, sz = .1,
  sv = .3, t0=.05)
pop.prior <- BuildPrior(
   dists = rep("tnorm", npar),
   p1    = pop.mean,
   p2    = pop.scale,
   lower = c(rep(0, 2), rep(-5, 2), rep(0, 4)),
   upper = c(rep(5, 2), rep(7, 2), rep(2, 4)))
```


As usual, I want to visually check if the assumed mechanism is reasonable.

```
plot(pop.prior)
```


I loaded the empirical data to see the trial number and participant number
in the empirical data.

```
load("data/race/study3.rda")
dplyr::tbl_df(study3)
## A tibble: 12,033 x 7
##       RT     S     B     CT   RACE  R     s
##    <dbl> <fct> <fct>  <fct>  <fct> <fct> <fct>
##  1 0.753   gun  blur   safe  black not     11
##  2 0.851   non  blur   safe  white shoot   11
##  3 0.742   gun  clear  safe  black not     11
##  4 0.636   non  clear  safe  white shoot   11
##  5 0.644   gun  blur   safe  black shoot   11
##  6 0.625   non  clear  safe  black not     11
##  7 0.889   non  clear  safe  white shoot   11
##  8 0.597   gun  blur   safe  black not     11
##  9 0.724   gun  clear  safe  white not     11
## 10 0.656   non  blur   safe  white shoot   11
## ... with 12,023 more rows



```

By using the internal function _.N_ in _data.table_, I knew the actual
trial number in a design cell is very small (6 to 33 trials) in study 3.
One more reason that I tested only RACE and S factor, which give
trial number between 50 to 93.  Later, I will tested another model,
which also has B and CT factors, to see whether
the HDDM still returns good estimates when the trial numbers are very
small.

1. s: subject id
2. S: stimulus factor
3. B: object factor: blurrd or clear view
4. CT: context factor: safe or dangerous neighbor

```
study3[, .N, .(s, S, B, CT, RACE)]
## 
##       s   S     B     CT  RACE  N
##   1:  11 gun  blur   safe black 22
##   2:  11 non  blur   safe white 23
##   3:  11 gun clear   safe black 19
##   4:  11 non clear   safe white 18
##   5:  11 non clear   safe black 21
##  ---                              
## 604: 348 gun clear danger black 17
## 605: 348 non clear danger white 28
## 606: 348 gun  blur danger white 20
## 607: 348 non clear danger black 16
## 608: 348 gun  blur danger black 23

range(study3[, .N, .(s, S, B, CT, RACE)]$N)
## [1] 6 33

study3[, .N, .(s, S, RACE)]
#        s   S  RACE  N
#   1:  11 gun black 82
#   2:  11 non white 82
#   3:  11 non black 78
#   4:  11 gun white 78
#   5:  19 gun white 83
# ---                 
# 148: 344 non black 84
# 149: 348 non white 93
# 150: 348 gun black 81
# 151: 348 gun white 79
# 152: 348 non black 67

range(study3[, .N, .(s, S, RACE)]$N)
## [1] 50 93

nrow(study3[, .N, .(s)])
## 38 subjects
```


Then I set up the same number of subjects / participants and an optimistic trial numbers.
```
nsubject <- 38
ntrial <- 100
dat <- simulate(model, nsim = ntrial, nsub = nsubject, p.prior = pop.prior)
dmi <- BindDataModel(dat, model)
ps <- attr(dat, "parameters")
```

Next I started the sampling. This will take a few hours.

```
## Set-up Priors --------
p.prior <- BuildPrior(
  dists = rep("tnorm", npar),
  p1    = pop.mean,
  p2    = pop.scale*10,
  lower = c(rep(0, 2), rep(-5, 2), rep(0, 4)),
  upper = c(rep(10, 2), rep(7, 2), rep(5, 4)))
mu.prior <- BuildPrior(
  dists = rep("tnorm", npar),
  p1    = pop.mean,
  p2    = pop.scale*10,
  lower = c(rep(0, 2), rep(-5, 2), rep(0, 4)),
  upper = c(rep(10, 2), rep(7, 2), rep(5, 4)))
sigma.prior <- BuildPrior(
  dists = rep("beta", npar),
  p1    = rep(1, npar),
  p2    = rep(1, npar),
  upper = rep(2, npar))
names(sigma.prior) <- GetPNames(model)
pp.prior <- list(mu.prior, sigma.prior)

## Sampling ----------
hsam <- run(StartNewHypersamples(5e2, dmi, p.prior, pp.prior, 16),
  pm = .3, hpm = .3)
hsam <- run(RestartHypersamples(5e2, hsam, thin = 32),
  pm = .3, hpm = .3) ## 3 hrs
hsam <- run(RestartHypersamples(5e2, hsam, thin = 16),
  pm = .3, hpm = .3) ## 90 mins

save(model, pop.prior, nsubject, ntrial, dat, dmi, hsam,
     file = "data/hierarchical/shoot-decision-recovery.rda")
```



As usual, I checked the model so as to know it is reliable.

1. Trace plots of posterior log-likelihood at hyper level
2. Trace plots of the hyper parameters
3. Trace plots of posterior log-likelihood at the data level
4. Trace plots of each DDM parameters for each participants
5. Posterior density plots (i.e., marginal posterior distributions) for the hyper parameters
6. Posterior density plots the DDM parameters for each parameters
7. Brook and Gelman potential scale reduction factors

```
plot(hsam, hyper = TRUE)                           ## 1.
plot(hsam, hyper = TRUE, pll = FALSE)              ## 2.
plot(hsam)                                         ## 3.
plot(hsam, pll = FALSE)                            ## 4.
plot(hsam, hyper = TRUE, pll = FALSE, den = TRUE)  ## 5.
plot(hsam, pll = FALSE, den = TRUE)                ## 6.
rhat <- hgelman(hsam)                              ## 7.
## Diagnosing theta for many participants separately
## Diagnosing the hyper parameters, phi
## hyper     1     2     3     4     5     6     7     8     9    10    11    12    13    14 
##  1.06  1.00  1.00  1.00  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01 
##    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29 
##  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01 
##    30    31    32    33    34    35    36    37    38 
##  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.01  1.03 
```


Then, I checked if my race-threshold model can recover the parameters.

```
hest1 <- summary(hsam, recovery = TRUE, hyper = TRUE, ps = pop.mean,  type = 1)
hest2 <- summary(hsam, recovery = TRUE, hyper = TRUE, ps = pop.scale, type = 2)
ests <- summary(hsam, recovery = TRUE, ps = ps)

## Summary each participant separately
##        a.E   a.A   v.G   v.N     z    sz    sv    t0
## Mean  1.58  2.61  4.12  3.00  0.48  0.32  1.02  0.22
## True  1.69  2.50  2.94  2.08  0.51  0.33  1.02  0.19
## Diff  0.11 -0.11 -1.18 -0.92  0.03  0.00  0.00 -0.02
## Sd    0.49  0.80  0.39  0.59  0.10  0.12  0.39  0.05
## True  0.46  0.82  0.44  0.51  0.10  0.09  0.35  0.05
## Diff -0.04  0.02  0.05 -0.08 -0.01 -0.03 -0.04  0.00

lapply(list(hest1, hest2), round, 2)
## Mean
##                 a.A  a.E    sv   sz   t0  v.G  v.N     z
## True           2.50 1.50  1.00 0.30 0.20 3.00 2.00  0.50
## 2.5% Estimate  2.32 1.39  0.58 0.09 0.20 3.88 2.75  0.44
## 50% Estimate   2.60 1.57  0.98 0.31 0.22 4.11 3.00  0.48
## 97.5% Estimate 2.89 1.75  1.18 0.39 0.23 4.36 3.25  0.51
## Median-True    0.10 0.07 -0.02 0.01 0.02 1.11 1.00 -0.02


```

The recovery study supports the hypothesis that the race-threshold model 
can recover the parameters reliably. Therefore, if this model is a true
model, we can use it to confirm or reject the hypothesis that 
a police office has a higher shoot threshold towards a black than 
a white target (i.e., _a.A > a.E_). Both at the level of individual
participants and at the level of hyper parameters. Of course, this
presumes that the hierarchical race-threshold model is an appropriate
model to better reflect the true phenomenon. That is, if the data do
reflect this hypothesis, my hierarchical DDM is able to reveal it. I
will return to the technique of model selection in a later tutorial.
Note without highly efficient software, like _ggdmc_, the model
selection work is very difficult to conduct.

Another strength in _ggdmc_ (as well as DMC), relative to the
Python-HDDM (Wiecki, Sofer & Frank, 2013) is that _ggdmc_ estimates
the DDM variabilities at the hyper level [^1]. I will return this
particular strength of _ggdmc_ in another tutorial.

```
## SD
##                 a.A  a.E   sv   sz   t0  v.G  v.N    z
## True           0.80 0.50 0.30 0.10 0.05 0.50 0.50 0.10
## 2.5% Estimate  0.67 0.41 0.33 0.10 0.04 0.34 0.50 0.09
## 50% Estimate   0.85 0.52 0.50 0.17 0.05 0.52 0.67 0.11
## 97.5% Estimate 1.14 0.71 0.85 0.32 0.07 0.74 0.90 0.14
## Median-True    0.05 0.02 0.20 0.07 0.00 0.02 0.17 0.01
```

Now I am ready to fit the empirical data with the race-threshold model.


[^1]: If one wishes to estimate the DDM variabilities at the hyper level in Python-HDDM, s/he would need to modify the Python-HDDM source codes, which is possible but less convenient.

## Reference
Pleskac, T.J., Cesario, J. & Johnson, D.J. (2017). How race affects evidence accumulation during the decision to shoot.
_Psychonomic Bulletin & Review_, 1-30. https://doi.org/10.3758/s13423-017-1369-6

Wong, J. C. (2016, Aprial, 18). ['Scapegoated?' The police killing that left Asian Americans angry – and divided](https://www.theguardian.com/world/2016/apr/18/peter-liang-akai-gurley-killing-asian-american-response).
_The Guardian_.

[Chinese Community Reels After Brooklyn NYPD Shooting](https://www.nbcnews.com/news/asian-america/chinese-community-reels-after-brooklyn-nypd-shooting-n273931). (2014, December 24). _NBC News_.

[American's police on trial](https://www.economist.com/leaders/2014/12/11/americas-police-on-trial). (2014, December, 11). _The Economist_.




