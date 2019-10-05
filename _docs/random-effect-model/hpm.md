---
title: HPM Model
category: Hierarchical Model
order: 7
---

> Disclaimer: This tutorial is to fit Strickland et al's (2018) PM model. For any questions regarding the model, please contact luke.strickland@uwa.edu.au

Here we continue the PM tutorial to show how to conduct a hierarchical PM model. 

```
FR <- list(S = c("n","w","p"), cond=c("C","F", "H"), R=c("N", "W", "P"))
lev <- c("CnN","CwN", "CnW","CwW",
         "FnN","FwN","FpN", "FnW","FwW","FpW", "fa","FpP",
         "HnN","HwN","HpN", "HnW","HwW","HpW", "HpP",
         "FAKERATE")
map_mean_v <- ggdmc:::MakeEmptyMap(FR, lev)
map_mean_v[1:27] <- c(
  "CnN","CwN","FAKERATE", "FnN","FwN","FpN", "HnN","HwN","HpN",
  "CnW","CwW","FAKERATE", "FnW","FwW","FpW", "HnW","HwW","HpW",
  "FAKERATE","FAKERATE","FAKERATE", "fa","fa","FpP", "fa","fa","HpP")

model0 <- BuildModel(
  p.map     = list(A = "1", B = c("cond", "R"), t0 = "1", mean_v = c("MAPMV"),
                   sd_v = "1", st0 = "1", N = "cond"),
  match.map = list(M = list(n = "N", w = "W", p = "P"), MAPMV = map_mean_v),
  factors   = list(S = c("n","w","p"), cond = c("C","F", "H")),
  constants = c(N.C = 2, N.F = 3, N.H = 3, st0 = 0, B.C.P = Inf,
                mean_v.FAKERATE = 1, sd_v = 1),
  responses = c("N", "W", "P"),
  type      = "norm")

npar <- length(GetPNames(model0))

pop.mean <- c(A = .3, B.C.N = 1.3,  B.F.N = 1.3,  B.H.N = 1.3,
              B.C.W = 1.3,  B.F.W = 1.4,  B.H.W = 1.5,
              B.F.P = 1.1,  B.H.P = 1.3,

              t0=.1,

              mean_v.CnN = 2.8,  mean_v.CwN = -0.3, mean_v.CnW=-1,
              mean_v.CwW = 2.9,  mean_v.FnN = 2.8,  mean_v.FwN=-.3,

              mean_v.FpN = -1.6, mean_v.FnW = -1,   mean_v.FwW = 2.9,
              mean_v.FpW = .5 ,  mean_v.fa = -2.4,  mean_v.FpP = 2.5,

              mean_v.HnN = 2.8, mean_v.HwN = -.5,   mean_v.HpN = -.6,
              mean_v.HnW = -.7, mean_v.HwW = 3.0,   mean_v.HpW = 1.6,
              mean_v.HpP = 2.3)

pop.scale <-c(A = .05, B.C.N = .05,  B.F.N = .05,  B.H.N = .05,
              B.C.W = .05,  B.F.W = .05,  B.H.W = .05,
              B.F.P = .05,  B.H.P = .05,

              t0=.05,

              mean_v.CnN = .05,  mean_v.CwN = .05, mean_v.CnW = .05,
              mean_v.CwW = .05,  mean_v.FnN = .05,  mean_v.FwN = .05,

              mean_v.FpN = .05, mean_v.FnW = .05,   mean_v.FwW = .05,
              mean_v.FpW = .05,  mean_v.fa = .05,  mean_v.FpP = .05,

              mean_v.HnN = .05, mean_v.HwN = .05,   mean_v.HpN = .05,
              mean_v.HnW = .05, mean_v.HwW = .05,   mean_v.HpW = .05,
              mean_v.HpP = .05)

pop.prior <- BuildPrior(
  dists = rep("tnorm", 29),
  p1 = pop.mean,
  p2 = pop.scale,
  lower = c(rep(0, 9), .1, rep(NA, 19)),
  upper = c(rep(NA,9),  1, rep(NA, 19)))

dat0 <- simulate(model0, nsub = 20, nsim = 30, prior = pop.prior)
dmi0 <- BuildDMI(dat0, model0)
ps0 <- attr(dat0, "parameters")

pname <- GetPNames(model0)
p.prior <- BuildPrior(
  dists = c(rep("tnorm", 9), "beta", rep("tnorm", 19)),
  p1    = rep(1, npar),
  p2    = c(rep(2, 9), 1, rep(2, 19)),
  lower = c(rep(0, 10),  rep(NA, 19)),
  upper = c(rep(NA, 9), 1, rep(NA, 19)))
mu.prior <- BuildPrior(
  dists = c(rep("tnorm", 9), "beta", rep("tnorm", 19)),
  p1    = rep(1, npar),
  p2    = c(rep(2, 9), 1, rep(2, 19)),
  lower = c(rep(0, 10),  rep(NA, 19)),
  upper = c(rep(NA, 9), 1, rep(NA, 19)))
sigma.prior <- BuildPrior(
  dists = rep("beta", npar),
  p1    = rep(1, npar),
  p2    = rep(1, npar))
names(p.prior) <- pname
names(mu.prior) <- pname
names(sigma.prior) <- pname
priors0 <- list(pprior=p.prior, location=mu.prior, scale=sigma.prior)

fit0 <- StartNewsamples(dmi0, priors0, thin = 2)
## 2 * 56 mins
fit0_correct  <- run(fit0, thin = 2)
save(fit0, fit0_correct, model0, dat0, dmi0, ps0, file = "tests/Group2/hPM1.RData")

rhat0 <- hgelman(fit0)
dev <- DIC(fit0_correct, BPIC = TRUE)


```
# Reference
* Strickland, L., Loft, S., Remington, R. W., & Heathcote, A. (2018). Racing to remember: A theory of decision control in event-based prospective memory. Psychological Review, 125(6), 851-887. http://dx.doi.org/10.1037/rev0000113


