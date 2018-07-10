---
title: One Participant
category: Fixed Effects Model
order: 1
---

Fixed effects models refer to a scenario / hypothesis that each participant
has her / his own parameter generating mechanisms. This is relative to
another scenario that all participants are under one common mechanism
of parameter generation, namely random effects / hierarchical / multi-level
models.

In this tutorial, I illustrated the method to conduct Bayesian MCMC sampling
on a single participant. Given a data set containing (1) response times and
(2) response choice, our general aim is to estimate the parameters generating
these response time (RT) and choice data. The sampling technique based on Bayesian MCMC helps
us to draw (posterior) samples from the probability distribution generating
the data, even we do not know the true parameters. For example, we know
the [Gaussian (normal distribution) function](https://en.wikipedia.org/wiki/Gaussian_function).
If we also know the values of its parameters, mean and standard deviation, 
we can draw its samples by, for instance, using R's _rnorm_ function,

```
mu <- 0
sigma <- 1
dat <- rnorm(1e3, mu, sigma)
```

![Gaussian]({{"/images/Gaussian.png" | relative_url}})

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
dmi <- BindDataModel(dat, model)
data.table(dmi)
#       S  R        RT
#   1: s1 r1 0.2473921
#   2: s1 r1 0.2781127
#   3: s1 r1 0.2512331
#   4: s1 r1 0.2556350
#   5: s1 r1 0.1779083
# ---
# 196: s2 r1 0.2955069
# 197: s2 r1 0.3175132
# 198: s2 r1 0.1908835
# 199: s2 r2 0.4205383
# 200: s2 r1 0.2491955
```

Because I simulated the data, I know the true parameter vector, _p.vector_, which
will be used later to verify whether the sampling process appropriately estimates 
the parameters. In Bayesian statistics, we also need prior distributions, so
let's build a set of prior distributions for each DDM parameters.

A beta distribution with shape1 = 1 and shape2 = 1, equals to a uniform
distribution (_beta(1, 1)_). This is for the start point, _z_, its variability
_sz_ and _t0_ parameters. All three are bounded by 0 and 1. Others use
truncated normal distributions bounding by _lower_ and _upper_ options.
_plot_ draws the prior distribution, providing a visual check method.

```
p.prior  <- BuildPrior(
  dists = c(rep("tnorm", 2), "beta", "beta", "tnorm", "beta"),
  p1    = c(a = 1, v = 0, z = 1, sz = 1, sv = 1, t0 = 1),
  p2    = c(a = 1, v = 2, z = 1, sz = 1, sv = 1, t0 = 1),
  lower = c(0, -5, NA, NA, 0, NA),
  upper = c(5,  5, NA, NA, 5, NA))
plot(p.prior)
```

![prior]({{"/images/prior.png" | relative_url}})


_StartNewsamples_ use p.prior to randomly draw start points. _pm_ means
the probability of using migration operator.  Here I set it as 5% chance.
_debug_ = TRUE switches on the old-style migration operator. I set thinning
length as 16, meaning every 16th step to store a sample.

```
sam <- run(StartNewsamples(5e2, dmi, p.prior, thin = 16), pm = .05, debug = TRUE)

plot(sam)
plot(sam, start = 101)

```

_plot_ by default draws posterior log-likelihood, with the option, _start_,
indicating that drawing from 101st sample, instead of from the first one.

![pll]({{"/images/pll.png" | relative_url}})

The left panel showed the chains quickly converged to posterior log-likelihoods
around 25, and the right panel showed all chains converged about 300
iterations. I drew another 500 samples as proper posterior samples. This
time, I switched off the migration operator.

```
sam <- run(RestartSamples(500, sam), pm = 0, debug = TRUE)
plot(sam, pll = FALSE, den= TRUE)

```

![den]({{"/images/den.png" | relative_url}})

We can also check reject rates to see the efficiency of the
sampler.

```
Chain   1: rejection rates:  0.76 
Chain   2: rejection rates:  0.77 
Chain   3: rejection rates:  0.76 
Chain   4: rejection rates:  0.76 
Chain   5: rejection rates:  0.77 
Chain   6: rejection rates:  0.77 
Chain   7: rejection rates:  0.76 
Chain   8: rejection rates:  0.76 
Chain   9: rejection rates:  0.76 
Chain  10: rejection rates:  0.77 
Chain  11: rejection rates:  0.76 
Chain  12: rejection rates:  0.77 
Chain  13: rejection rates:  0.77 
Chain  14: rejection rates:  0.77 
Chain  15: rejection rates:  0.76 
Chain  16: rejection rates:  0.76 
Chain  17: rejection rates:  0.76 
Chain  18: rejection rates:  0.76
```

In a simulation / parameter-recovery study, we can check whether
the sampling process is OK, using _summary_

```
est <- summary(sam, recover = TRUE, ps = p.vector)
round(est, 2)
#                   a   sv   sz   t0    v    z
# True           1.00 0.20 0.25 0.15 1.20 0.38
# 2.5% Estimate  0.95 0.20 0.02 0.14 0.90 0.35
# 50% Estimate   1.05 1.26 0.29 0.15 1.36 0.39
# 97.5% Estimate 1.20 2.51 0.58 0.16 2.01 0.42
# Median-True    0.05 1.06 0.04 0.00 0.16 0.01
```
[^1]: This is often dubbed, drift-diffusion model, but in Ratcliff and McKoon's work, they called it diffusion decision model. 



