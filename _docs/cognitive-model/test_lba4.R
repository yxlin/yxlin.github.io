cat("\n-------------------- Testing 4 Acc HLBA --------------------")
rm(list = ls())
## setwd('/media/yslin/MERLIN/Documents/ggdmc/tests/testthat/Group2_LBA/')
## setwd('/Data/user_yslin/tests/testthat/Group2_LBA')
## setwd('/home/yslin/yxlin.github.io-master/_docs/cognitive-model/')
require(ggdmc)

## 4 stimuli that have a shape and color (blue_diamond, blue_heart, green_diamond, and green_heart)
## I assume a difficulty hierarchy (from easy to hard): green_diamond (e1) > green_heart (e2) > blue_diamond (e3) > blue_heart (e4). I also assume the easier stimulus, the higher its drift rate and the more variable its drift rate standard deviation. 
model <- BuildModel(
    p.map     = list(A = "1", B = "R", t0 = "1", mean_v = c("S", "M"),
                     sd_v = "M", st0 = "1"),
    match.map = list(M = list("blue_diamond" = "BD", "blue_heart" = "BH",
                              "green_diamond" = "GD", "green_heart" = "GH")),
    factors   = list(S = c("blue_diamond", "blue_heart", "green_diamond", "green_heart")),
    constants = c(sd_v.false = 1, st0 = 0),
    responses = c("BD", "BH", "GD", "GH"),
    type      = "norm")
model@npar

pop.mean <- c(A=.4, B.BD=.5, B.BH=.6, B.GD=.7, B.GH=.8,
              t0=.3,
              mean_v.blue_diamond.true   = 1.5,
              mean_v.blue_heart.true     = 1.0,
              mean_v.green_diamond.true  = 2.5,
              mean_v.green_heart.true    = 2.0,
              mean_v.blue_diamond.false  = .20,
              mean_v.blue_heart.false    = .25,
              mean_v.green_diamond.false = .10,
              mean_v.green_heart.false   = .15,
              sd_v.true = .25)

pop.scale <-c(A=.1, B.BD=.1, B.BH=.1, B.GD=.1, B.GH=.1,
              t0=.05,
              mean_v.blue_diamond.true   = .2,
              mean_v.blue_heart.true     = .2,
              mean_v.green_diamond.true  = .2,
              mean_v.green_heart.true    = .2,
              mean_v.blue_diamond.false  = .2,
              mean_v.blue_heart.false    = .2,
              mean_v.green_diamond.false = .2,
              mean_v.green_heart.false   = .2,
              sd_v.true = .1)

pop.prior <- BuildPrior(
     dists = rep("tnorm", model@npar),
     p1 = pop.mean,
     p2 = pop.scale,
     lower = c(0,0,0,0,0,        .05, NA,NA,NA,NA, NA,NA,NA,NA, 0),
    upper = c(NA,NA,NA,NA,NA,    1, NA,NA,NA,NA, NA,NA,NA,NA, NA))

## plot(pop.prior)
## Simulate some data ----------
dat <- simulate(model, nsub = 12, nsim = 30, prior = pop.prior)
dmi <- BuildDMI(dat, model)
ps <- attr(dat, "parameters")

p.prior <- BuildPrior(
    dists = rep("tnorm", model@npar),
    p1   = pop.mean,
    p2   = pop.scale*5,
    lower = c(0,0,0,0,0,        .05, NA,NA,NA,NA, NA,NA,NA,NA, 0),
    upper = c(NA,NA,NA,NA,NA,    1, NA,NA,NA,NA, NA,NA,NA,NA, NA))

mu.prior <- BuildPrior(
    dists = rep("tnorm",  model@npar),
    p1    = pop.mean,
    p2    = c(1,1,1,1,1,  1, 2,2,2,2, 2,2,2,2, 2),
    lower = c(0,0,0,0,0,       .05, NA,NA,NA,NA, NA,NA,NA,NA, 0),
    upper = c(NA,NA,NA,NA,NA,    1, NA,NA,NA,NA, NA,NA,NA,NA, NA))

plot(p.prior, ps=ps)
plot(mu.prior, ps = pop.mean)

sigma.prior <- BuildPrior(
    dists = rep("unif", model@npar),
    p1    = c(A = 0, B.BD = 0, B.BH = 0, B.GD=0, B.GH=0,
              t0 = 0,
              mean_v.blue_diamond.true   = 0,
              mean_v.blue_heart.true     = 0,
              mean_v.green_diamond.true  = 0,
              mean_v.green_heart.true    = 0,
              mean_v.blue_diamond.false  = 0,
              mean_v.blue_heart.false    = 0,
              mean_v.green_diamond.false = 0,
              mean_v.green_heart.false   = 0,
              sd_v.true = 0),
    p2    = rep(5, model@npar))

## plot(sigma.prior, ps=pop.scale)
## Sampling -------------
priors <- list(pprior=p.prior, location=mu.prior, scale=sigma.prior)

## Enter only the participant-level prior distribution will render the function to
## run fixed-effect model
## Use nmc = 10 to estimate how much time would take.
## 42.22

fit0 <- StartNewsamples(dmi, prior=p.prior, ncore=4)


fit  <- run(fit0, ncore = 4)
## Processing time: 660.6 secs.
save(fit0, fit, model, pop.mean, pop.scale, pop.prior, dat, dmi, ps, p.prior,
     mu.prior, sigma.prior, priors, file = "data/LBA4A.RData")
## Processing time: 918.65 secs.
fit  <- run(fit, thin = 2, ncore = 6)
save(fit0, fit, model, pop.mean, pop.scale, pop.prior, dat, dmi, ps, p.prior,
     mu.prior, sigma.prior, priors, file = "data/LBA4A.RData")

## Processing time: 1845.87 secs.
fit  <- run(fit, thin = 4, ncore = 6)
save(fit0, fit, model, pop.mean, pop.scale, pop.prior, dat, dmi, ps, p.prior,
     mu.prior, sigma.prior, priors, file = "data/LBA4A.RData")

## Processing time: 3676.04 secs.
fit  <- run(fit, thin = 8, ncore = 6)
save(fit0, fit, model, pop.mean, pop.scale, pop.prior, dat, dmi, ps, p.prior,
     mu.prior, sigma.prior, priors, file = "data/LBA4A.RData")

fit  <- run(fit, thin = 12, ncore = 6)
save(fit0, fit, model, pop.mean, pop.scale, pop.prior, dat, dmi, ps, p.prior,
     mu.prior, sigma.prior, priors, file = "data/LBA4A.RData")

load('data/LBA4A.RData')
plot(fit)
plot(fit, subchain=TRUE, nsubchain=3)
plot(fit, subchain=TRUE, nsubchain=2)

res <- gelman(fit, verbose = TRUE)
res <- gelman(fit, verbose = TRUE, subchain=1:4)
res <- gelman(fit, verbose = TRUE, subchain=5:8)
res <- gelman(fit, verbose = TRUE, subchain=9:12)
## Mean    8   12    1   11    5    2   10    9    3    6    7    4
## 2.94 1.16 1.44 1.78 1.99 2.32 2.49 3.22 3.62 3.65 3.70 4.72 5.18
## Mean    8    2    5   12    3   10   11    4    6    7    1    9
## 2.14 1.08 1.31 1.47 1.54 1.97 2.17 2.24 2.32 2.59 2.60 2.81 3.63
## Mean    8    5    2    6   12    9    7   10    3    4    1   11
## 1.54 1.10 1.23 1.25 1.25 1.29 1.35 1.47 1.48 1.54 1.73 1.78 2.97

## Mean    8    5    2    6   12    7   10    3    4    9    1   11 
## 1.33 1.06 1.14 1.15 1.18 1.26 1.26 1.31 1.34 1.35 1.36 1.59 1.94 

load('data/LBA4A.RData'); ls()
est0 <- summary(fit, recovery = TRUE, ps = ps, verbose =TRUE)

##            A    B.r1    B.r2    B.r3    B.r4      t0 mean_v.d1.true
## Mean  0.3652  0.5590  0.6447  0.8768  0.9125  0.2845         2.7431
## True  0.3668  0.4815  0.5696  0.7796  0.8150  0.2962         2.5801
## Diff  0.0016 -0.0776 -0.0752 -0.0971 -0.0976  0.0117        -0.1630

## Sd    0.0872  0.1493  0.1536  0.1690  0.0922  0.0479         0.1589
## True  0.0853  0.1176  0.1164  0.1232  0.1038  0.0376         0.1680
## Diff -0.0020 -0.0317 -0.0372 -0.0458  0.0117 -0.0103         0.0091

##      mean_v.d2.true mean_v.d3.true mean_v.d4.true mean_v.d1.false
## Mean         2.1192         1.6674         1.0673          0.2830
## True         1.9951         1.5523         0.9802          0.2003
## Diff        -0.1241        -0.1151        -0.0871         -0.0827

## Sd           0.2373         0.2388         0.2542          0.3852
## True         0.1994         0.2404         0.1994          0.1492
## Diff        -0.0379         0.0016        -0.0548         -0.2360

##      mean_v.d2.false mean_v.d3.false mean_v.d4.false sd_v.true
## Mean          0.3590          0.5187          0.3383    0.2822
## True          0.1814          0.3344          0.2137    0.2598
## Diff         -0.1775         -0.1843         -0.1245   -0.0224

## Sd            0.2888          0.2671          0.2023    0.1230
## True          0.1943          0.1948          0.1579    0.1037
## Diff         -0.0945         -0.0724         -0.0445   -0.0193

