---
title: One Participant
category: Fixed Effects Model
order: 1
---

Fixed effects models refer to a scenario that each participant / subject
has her own parameter generating mechanism. This is relative to
another scenario that all participants are under one common mechanism
of parameter generation.  The latter scenario sometimes is dubbed
random effects, hierarchical or multi-level models, although each term has
slightly different meanings. 

In this tutorial, I illustrate the method of conducting Bayesian MCMC sampling
in the fixed-effects scenario. Given a data set containing (1) response times
and (2) response choices, our general aim is to estimate the parameters
generating the response latency and choices. The sampling technique based on
Bayesian MCMC helps to draw (posterior) samples from the probability
distribution generating the data, even we do not know the exact
mathematical form of this particular probability distribution.

For example, we know the [Gaussian (normal distribution) function](https://en.wikipedia.org/wiki/Gaussian_function). If we also know the values of its parameters,
mean and standard deviation, we can draw its samples by, for instance,
using R's _rnorm_ function,

```
mu <- 0
sigma <- 1
dat <- rnorm(1e3, mu, sigma)
```

![Gaussian]({{"/images/fixed-effect-model/Gaussian.png" | relative_url}})

The usual situation is that we would collect data (_dat_) by inviting
participants to visit our lab, having them perform some sort of
cognitive tasks and in the meantime recording their RTs and choices. 
In this more realistic situation, we need to estimate _mu_
and _sigma_.  Of course, this presumes that if we are willing to
assume that the Gaussian is the model accounting for participants'
particular behaviours when they are doing the cognitive tasks.

More often, we would use a popular RT model, diffusion decision model
(DDM) (Ratcliff & McKoon, 2008)[^1]. As usual, I firstly set up a model
object. The _type_ = **"rd"**, refers to Ratcliff's diffusion model.

```
model <- BuildModel(
  p.map     = list(a = "1", v = "1", z = "1", d = "1", sz = "1", sv = "1",
                   t0 = "1", st0 = "1"),
  match.map = list(M = list(s1 = "r1", s2 = "r2")),
  factors   = list(S = c("s1", "s2")),
  responses = c("r1", "r2"),
  constants = c(st0 = 0, d = 0),
  type      = "rd")

p.vector <- c(a = 1, v = 1.2, z = .38, sz = .25, sv = .2, t0 = .15)
ntrial <- 1e2
dat <- simulate(model, nsim = ntrial, ps = p.vector)
dmi <- BuildDMI(dat, model)
## A tibble: 200 x 3     ## use dplyr::tbl_df(dat) to print this
##    S     R        RT
##    <fct> <fct> <dbl>
##  1 s1    r1    0.249
##  2 s1    r1    0.246
##  3 s1    r2    0.262
##  4 s1    r1    0.519
##  5 s1    r1    0.205
##  6 s1    r1    0.177
##  7 s1    r1    0.174
##  8 s1    r1    0.378
##  9 s1    r1    0.197
## 10 s1    r1    0.224
##  ... with 190 more rows

```

Because the data were simulated from a set of presume true values, _p.vector_,
I can use them later to verify whether the sampling process appropriately
estimates the parameters. In Bayesian statistics, we also need prior
distributions, so let's build a set of prior distributions for each
DDM parameters.

A beta distribution with shape1 = 1 and shape2 = 1, equals to a uniform
distribution (_beta(1, 1)_). This is for the start point, _z_, its variability
_sz_ and _t0_ parameters. All three are bounded by 0 and 1. Others use
truncated normal distributions bounding by _lower_ and _upper_ arguments.
_plot_ draws the prior distribution, providing a visual check method.

```
p.prior  <- BuildPrior(
  dists = c(rep("tnorm", 2), "beta", "beta", "tnorm", "beta"),
  p1    = c(a = 1, v = 0, z = 1, sz = 1, sv = 1, t0 = 1),
  p2    = c(a = 1, v = 2, z = 1, sz = 1, sv = 1, t0 = 1),
  lower = c(0, -5, NA, NA, 0, NA),
  upper = c(5,  5, NA, NA, 5, NA))
plot(p.prior, ps = p.vector)
```

![prior]({{"/images/fixed-effect-model/prior.png" | relative_url}})


_StartNewsamples_ use p.prior to randomly draw start points. The
initialized samples are fed to run function to start sampling. I use
the repeat function to rerun the sampling until the convenient
convergence diagnosis index, _rhat_ smaller than 1.1.

```
path <- c("data/ggdmc_3_7_DDM.rda")
fit0 <- run(StartNewsamples(5e2, dmi, p.prior))
fit <- fit0
thin <- 1
repeat {
  fit <- run(RestartSamples(5e2, fit, thin = thin))
  save(fit, file = path[1])
  rhat <- gelman(fit, verbose = TRUE)
  if (all(rhat$mpsrf < 1.1)) break
  thin <- thin * 2
}
cat("Done ", path[1], "\n")
```

_plot_ by default draws posterior log-likelihood, with the option, _start_,
indicating that drawing from 101st sample, instead of from the first one.
I plot the two posterior log-likelihood samples to show the transit of
convergence.

```
p0 <- plot(fit0)
p1 <- plot(fit0, start = 101)

png("pll.png", 800, 600)
gridExtra::grid.arrange(p0, p1, ncol = 1)
dev.off()
```

![pll]({{"/images/fixed-effect-model/pll.png" | relative_url}})

The upper panel showed the chains quickly converged to posterior log-likelihoods
near 100th iteration and the right panel showed all chains converged after 100th
iterations. I drew final samples (sam) as proper posterior samples. I make
sure it is converged by using the _repeat_ method. 

```
plot(fit, pll = FALSE, den= TRUE)
```

![den]({{"/images/fixed-effect-model/den.png" | relative_url}})

In a simulation / parameter-recovery study, we can check whether
the sampling process is OK, using _summary_

```
est <- summary(fit, recover = TRUE, ps = p.vector, verbose = TRUE)
##                   a   sv   sz   t0    v    z
## True           1.00 0.20 0.25 0.15 1.20 0.38
## 2.5% Estimate  0.95 0.20 0.02 0.14 0.90 0.35
## 50% Estimate   1.05 1.26 0.29 0.15 1.36 0.39
## 97.5% Estimate 1.20 2.51 0.58 0.16 2.01 0.42
## Median-True    0.05 1.06 0.04 0.00 0.16 0.01
```

Finally, it would be a good idea to check if the model fit the data
well.  There are many methods to to quantify the goodness of fit.
Here, I illustrate two methods. First, I use DIC and BPIC. These
information criteria are useful for model selection. 
(need > ggdmc 2.5.5)
```
DIC(fit)  
BPIC(fit)
```

Secondly, I simulate post-predictive data, based on the parameter estimates.
_xlim_ trims off outlier values in the simulation data.

```
pp <- predict_one(fit, xlim = c(0, 5))
dat$C <- ifelse(dat$S == "s1"  & dat$R == "r1",  TRUE,
         ifelse(dat$S == "s2" & dat$R == "r2", TRUE,
         ifelse(dat$S == "s1"  & dat$R == "r2", FALSE,
         ifelse(dat$S == "s2" & dat$R == "r1",  FALSE, NA))))
pp$C <- ifelse(pp$S == "s1"  & pp$R == "r1",  TRUE,
        ifelse(pp$S == "s2" & pp$R == "r2", TRUE,
        ifelse(pp$S == "s1"  & pp$R == "r2", FALSE,
        ifelse(pp$S == "s2" & pp$R == "r1",  FALSE, NA))))

dat$reps <- NA
dat$type <- "Data"
pp$reps <- factor(pp$reps)
pp$type <- "Simulation"

DT <- rbind(dat, pp)
p1 <- ggplot(DT, aes(RT, color = reps, size = type)) +
  geom_freqpoly(binwidth = .05) +
  scale_size_manual(values = c(1, .3)) +
  scale_color_grey(na.value = "black") +
  theme(legend.position = "none") +
  facet_grid(S ~ C)


```
![post-predictive]({{"/images/fixed-effect-model/post-predictive.png" | relative_url}})

The grey lines are model predictions. By default, predict_one randomly select 100
parameter estimates and simulate data based on them.  Therefore, there are 100 grey lines,
which conveniently shows the variability of prediction. The solid dark line is the
data, in the case, appropriately fall within the range covering by the grey lines.
Note that the error responses (FALSE) are not predicted as well as the correct responses.
This is fairly common, because the number of per-condition trials is only 100.



[^1]: This is often dubbed, drift-diffusion model, but in Ratcliff and McKoon's work, they called it diffusion decision model. 



