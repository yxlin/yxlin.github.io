---
title: CDDM 
category: Fixed-effects Model
order: 3
---

> **Disclaimer**: We have striven to minimize the number of errors. However, we cannot guarantee the note is 100% accurate. This note records the codes for fitting fixed-effect 2-D diffusion model. The explanation will be added later.

First, we set up a 2-D diffusion model, simulate a data set and then define a set of prior distribution for the CDDM parameters.  

```
rm(list = ls())
require(ggdmc)

nw <- 4

model <- BuildModel(
  p.map     = list(v1 = "1", v2 = "1", a = "1", t0 = "1", sigma1="1",
                   sigma2="1", eta1="1", eta2="1", tmax="1", h="1"),
  match.map = NULL,
  constants = c(sigma1 = 1, sigma2 = 1, eta1=0, eta2=0, tmax=6, h=1e-4),
  factors   = list(S = c("s1", "s2")),
  responses = paste0('theta_', letters[1:nw]),
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

## Simulate data
dat <- simulate(model, nsub = 12, nsim = 1e2, prior = pop.prior)
ps <- attr(dat, "parameters")
dmi <- BuildDMI(dat, model)

p.prior <- BuildPrior(
  dists = rep("tnorm", npar),
  p1=c(v1=0, v2=0, a=1, t0=1),
  p2=c(v1=2, v2=2, a=2, t0=2),
  lower = c(-5, -5, rep(0, 2)),
  upper = rep(NA, npar))

plot(pop.prior, ps=ps)
plot(p.prior, ps=ps)
save(dmi, p.prior, model, ps, pop.mean, pop.scale, file = "tests/Group5/test_cddm12S.RData")
```


Then we use 6 CPU cores, **ncore=6** to run 6 parallel model fits. The **block** option indicates whether we want to update the entire parameter vector or just one parameter in the vector at a time. This is critical for the hierarchical model fit, but inconsequential for the fixed-effect model fit, so to gain more speed, we choose to disable it, **block=FALSE**. 

> Note in R 3.6.1, the **mc.cores** option in **mclapply** has been altered. It now takes the ncore option via "getOpion("mc.cores", 2L)". This renders the ggdmc 0.2.6.0 always run 2 cores, which is a default setting of the mclapply function. To launch the number of CPU core you want, you have to adjust this manually in the two internal R functions, **run_many** and **rerun_many**, accordingly. 
 

```
## 2 mins
system.time(
  fit0 <- StartNewsamples(dmi, p.prior, block = FALSE, nmc=500, ncore=6)
)

## 507 s
system.time(
  fit  <- run(fit0, ncore=6)
)
```

After finishing the model fit, we check whether the chains are well-converged. The potential scale reduction factors, PSRT, are below 1.10 for the data from the 12 participants.  

```
rhat <- gelman(fit, verbose=TRUE)
# Diagnosing theta for many participants separately
# Mean    5    3   10    7    1    4    2   11    8   12    6    9 
# 1.02 1.01 1.01 1.01 1.01 1.01 1.01 1.01 1.02 1.02 1.02 1.03 1.10 

est <- summary(fit, recovery = TRUE, ps = ps, verbose = FALSE)
```

The parameters are well recovered. 

```
# Summary each participant separately
#         v1    v2     a   t0
# Mean  1.98  1.92  1.52 0.12
# True  1.98  2.01  1.49 0.12
# Diff  0.00  0.10 -0.03 0.00
# Sd    0.14  0.17  0.12 0.04
# True  0.08  0.09  0.07 0.04
# Diff -0.06 -0.08 -0.05 0.00
```


