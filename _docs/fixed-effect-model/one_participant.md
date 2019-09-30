---
title: One Participant
category: Fixed-effects Model
order: 1
---

Fixed-effects models assume participants own separate mechanisms of 
parameter generation. This is relative to the random-effect models, where
they are under a common mechanism of parameter generation.  The latter
is sometimes described as hierarchical or multi-level models, although they 
can carry subtle different concepts.

In this tutorial, I illustrate the method of conducting Bayesian sampling
of the fixed-effects models. Given many observations of response latency
and choices, one modelling aim is to estimate the parameters that
generate the observations. Bayesian sampling helps to draw samples 
from the probability distribution generating the data.

The usual situation is that we would collect data (_dat_) by inviting
participants to visit our lab, having them perform some sort of
cognitive tasks and in the meantime recording their RTs and choices. 
In this more realistic situation, we need to estimate _mu_
and _sigma_.  Of course, this presumes that if we 
assume that the Gaussian is the model accounting for participants'
particular behaviours when they are doing the cognitive tasks.

More often, we would use a RT model, for example diffusion decision model
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
truncated normal distributions bounded by _lower_ and _upper_ arguments.
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


By default _StartNewsamples_ uses p.prior to randomly draw start
points and 500 MCMC samples.  This step uses a mixture of crossover
and migration operators. The _run_ function by default draw 500
MCMC samples, using only crossover operator. _gelman_ function
report rhat value of 1.06 in this case. A rhat value less than 1.1
is usually considered an indication of chains converged.

```
fit0 <- StartNewsamples(dmi, p.prior)
fit  <- run(fit0)
rhat <- gelman(fit, verbose = TRUE)
## Diagnosing a single participant, theta. Rhat = 1.06

```

_plot_ by default draws posterior log-likelihood, with the option, _start_,
to change to a latter start iteration to draw. 

```
p0 <- plot(fit0)
## p0 <- plot(fit0, start = 101)
p1 <- plot(fit)

png("pll.png", 800, 600)
gridExtra::grid.arrange(p0, p1, ncol = 1)
dev.off()
```

![pll]({{"/images/fixed-effect-model/pll.png" | relative_url}})

The upper panel showed the chains quickly converged to posterior log-likelihoods
near 100th iteration and the right panel confirmed the rhat value (< 1.1).

```
p2 <- plot(fit, pll = FALSE, den= FALSE)
p3 <- plot(fit, pll = FALSE, den= TRUE)
png("den.png", 800, 600)
gridExtra::grid.arrange(p2, p3, ncol = 1)
dev.off()

```

![den]({{"/images/fixed-effect-model/den.png" | relative_url}})

In a simulation study, we can check whether the sampling process is OK,
using _summary_

```
est <- summary(fit, recover = TRUE, ps = p.vector, verbose = TRUE)
##                   a   sv    sz   t0    v     z
## True           1.00 0.20  0.25 0.15 1.20  0.38
## 2.5% Estimate  0.99 0.02  0.01 0.14 1.09  0.32
## 50% Estimate   1.07 0.41  0.22 0.15 1.45  0.35
## 97.5% Estimate 1.16 1.18  0.43 0.16 1.81  0.39
## Median-True    0.07 0.21 -0.03 0.00 0.25 -0.03
```

Finally, we may want to check whether the model fits the data
well.  There are many methods to to quantify the goodness of fit.
Here, I illustrate two methods. First method is to calculate DIC
and BPIC. These information criteria are useful for model selection. 
(need > ggdmc 2.5.5)
```
DIC(fit)
BPIC(fit)
```

Secondly, I simulate post-predictive data, based on the parameter estimates.
_xlim_ trims off outlier values in the simulation data.

```
predict_one <- function(object, npost = 100, rand = TRUE, factors = NA,
                        xlim = NA, seed = NULL)
{
  model <- attributes(object$data)$model
  facs <- names(attr(model, "factors"))
  class(object$data) <- c("data.frame", "list")

  if (!is.null(factors))
  {
    if (any(is.na(factors))) factors <- facs
    if (!all(factors %in% facs))
      stop(paste("Factors argument must contain one or more of:",
                 paste(facs, collapse=",")))
  }

  resp <- names(attr(model, "responses"))
  ns   <- table(object$data[,facs], dnn = facs)
  npar   <- object$n.pars
  nchain <- object$n.chains
  nmc    <- object$nmc
  ntsample <- nchain * nmc
  pnames   <- object$p.names
  thetas <- matrix(aperm(object$theta, c(3,2,1)), ncol = npar)

  colnames(thetas) <- pnames

  if (is.na(npost)) {
    use <- 1:ntsample
  } else {
    if (rand) {
      use <- sample(1:ntsample, npost, replace = F)
    } else {
      use <- round(seq(1, ntsample, length.out = npost))
    }
  }

  npost  <- length(use)
  posts   <- thetas[use, ]
  nttrial <- sum(ns) ## number of total trials

  v <- lapply(1:npost, function(i) {
    simulate_one(model, n = ns, ps = posts[i,], seed = seed)
  })
  out <- data.table::rbindlist(v)
  reps <- rep(1:npost, each = nttrial)
  out <- cbind(reps, out)

  if (!any(is.na(xlim)))
  {
    out <- out[RT > xlim[1] & RT < xlim[2]]
  }

  attr(out, "data") <- object$data
  return(out)
}


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


d <- data.table::data.table(dat)
d[, .N, .(S, R)]
##     S  R  N
## 1: s1 r1 87
## 2: s1 r2 13
## 3: s2 r1 34
## 4: s2 r2 66
```
![post-predictive]({{"/images/fixed-effect-model/post-predictive.png" | relative_url}})

The grey lines are model predictions. By default, predict_one randomly draws 100
parameter estimates and simulate data based on them.  Therefore, there are 100 
lines, showing the prediction variability. The solid dark line is
the data, in the case, appropriately fall within the range covering by the grey lines.
Note that the error responses (FALSE) are not predicted as well as the correct responses.
This is fairly common, when the number of trial is minimal. In this case, it has only
13 trials.




[^1]: This is often dubbed, drift-diffusion model, but in Ratcliff and McKoon's work, they called it diffusion decision model. 


