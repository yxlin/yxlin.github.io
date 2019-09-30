---
title: HCDDM 
category: Hierarchical Model
order: 6
---

> **Disclaimer**: We have striven to minimize the number of errors. However, we cannot guarantee the note is 100% accurate. This note records the codes for fitting hierarchical 2-D diffusion model. The explanation will be added later.

First, we set up a 2-D diffusion model, simulate a data set and then define three sets of prior distributions for the CDDM parameters.  

```
model <- BuildModel(
  p.map     = list(v1 = "1", v2 = "1", a = "1", t0 = "1", sigma1="1",
                   sigma2="1", eta1="1", eta2="1", tmax="1", h="1"),
  match.map = NULL,
  constants = c(sigma1 = 1, sigma2 = 1, eta1=0, eta2=0, tmax=6, h=1e-4),
  factors   = list(S = c("s1", "s2")),
  responses = paste0('theta_', letters[1:4]),
  type      = "cddm")
npar <- length(GetPNames(model))

pop.mean  <- c(v1 =  2,  v2 =  2,  a = 1.5, t0=0.1)
pop.scale <- c(v1 = .1,  v2 = .1,  a = .05, t0=0.05)
pop.prior <- BuildPrior(
  dists = rep("tnorm", npar),
  p1    = pop.mean,
  p2    = pop.scale,
  lower = c(-5, -5,  0, 0),
  upper = c( 5,  5,  5, 2))

## Simulate some data
dat <- simulate(model, nsub = 12, nsim = 1e2, prior = pop.prior)
ps <- attr(dat, "parameters")
dmi <- BuildDMI(dat, model)

p.prior <- BuildPrior(
 dists = rep("tnorm", npar),
 p1=c(v1=0, v2=0, a=1, t0=1),
 p2=c(v1=2, v2=2, a=2, t0=1),
 lower = c(-5, -5, rep(0, 2)),
 upper = rep(NA, npar))

mu.prior <- ggdmc::BuildPrior(
   dists = rep("tnorm", npar),
   p1    = pop.mean,
   p2    = pop.scale*5,
   lower = c(-5,-5, 0, 0),
   upper = c(5,  5, 5, 1)
)

sigma.prior <- BuildPrior(
   dists = rep("beta", npar),
   p1    = c(v1=1, v2=1, a = 1, t0=1),
   p2    = rep(1, npar),
   upper = rep(NA, npar))

priors <- list(pprior=p.prior, location=mu.prior, scale=sigma.prior)

```

A conventional practice in our parameter-recovery study is to check the prior distributions 

```
plot(pop.prior, ps=ps)
plot(p.prior,   ps=ps)
plot(mu.prior)
plot(sigma.prior)

save(priors, dmi, model, ps, pop.mean, pop.scale, file = "tests/Group5/test_hcddm12S.RData")
```

The hierarchical model fit takes usually more time than the fixed-effect model fit.

```
## 23.7 mins
fit0 <- StartNewsamples(dmi, priors, nmc=5e2)

## 25.8 mins
fit  <- run(fit0)

## 51.5 mins
fit  <- run(fit, thin=2)
save(fit, fit0, priors, dmi, model, ps, pop.mean, pop.scale,
     file = "tests/Group5/test_hcddm12S.RData")
```

The PSRT reports the chains are converged.

```
res <- hgelman(fit, verbose = TRUE)
## hyper    10     6     4     2     5    12    11     9     7     3     8     1 
##  1.14  1.02  1.02  1.03  1.04  1.04  1.04  1.05  1.06  1.10  1.13  1.14  1.16 
```

The estimates averaged across particiapnts and their standard deviations are close to the true values.

```
est0 <- summary(fit, recovery = TRUE, ps = ps, verbose = TRUE)

#         v1   v2     a   t0
# Mean  2.03 1.92  1.54 0.10
# True  1.99 2.03  1.51 0.10
# Diff -0.04 0.11 -0.03 0.00
# Sd    0.11 0.11  0.02 0.05
# True  0.11 0.11  0.03 0.04
# Diff  0.00 0.00  0.02 0.00
```

The estimates of the hyper parameters are fairly close to the true values, too.
```
est1 <- summary(fit, hyper = TRUE, recovery = TRUE, ps = pop.mean,  type = 1, verbose = TRUE)
#                   a    t0   v1    v2
# True           1.50  0.10 2.00  2.00
# 2.5% Estimate  1.50  0.01 1.90  1.79
# 50% Estimate   1.54  0.09 2.03  1.92
# 97.5% Estimate 1.58  0.13 2.16  2.04
# Median-True    0.04 -0.01 0.03 -0.08

```

```
est2 <- summary(fit, hyper = TRUE, recovery = TRUE, ps = pop.scale, type = 2, verbose = TRUE)

#                    a   t0   v1   v2
# True            0.05 0.05 0.10 0.10
# 2.5% Estimate   0.01 0.04 0.09 0.08
# 50% Estimate    0.04 0.07 0.17 0.16
# 97.5% Estimate  0.11 0.14 0.34 0.32
# Median-True    -0.01 0.02 0.07 0.06
```
