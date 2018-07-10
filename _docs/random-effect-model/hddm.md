---
title: Hierarchical DDM
category: Hierarchical Model
order: 2
---

In this section, I will conduct parameter recovery study, demonstrating
the pMCMC method to conduct hierarchical DDM for a relatively simple
factorial design.


## Set up a model object,
This particular design is drawn from Heathcote et al's (2018) DMC tutorial,
which assumes that a word frequency (my interpretation) factor affecting
the mean drift rate (_v_). Note it is not a good practice to use "F" notation
in R, because it is also used as a shorthand for the reserved word,
meaning _FALSE_. However, one of the R strengths is it permits
idiosyncratic programming habits, even bad ones.

```
library(ggdmc)
model <- BuildModel(
    p.map     = list(a = "1", v = "F", z = "1", d = "1", sz = "1", sv = "1",
                     t0 = "1", st0 = "1"),
    match.map = list(M = list(s1 = "r1", s2 = "r2")),
    factors   = list(S = c("s1", "s2"), F = c("f1", "f2")),
    constants = c(st0 = 0, d = 0),
    responses = c("r1", "r2"),
    type      = "rd")
npar <- length(GetPNames(model))
```

To conduct a parameter recovery study, I firstly assumed a hidden
multi-level mechanism generating the data. That is, I presumed
there is a distribution at the population / participants level. This
distribution is a 7 dimension distribution, which has 7 marginal
distributions.  Each of them is in control of one DDM parameter.

```
pop.mean  <- c(a = 2,  v.f1 = 4, v.f2 = 3,  z = .5, sz = .3, sv = 1,  t0 = .3)
pop.scale <- c(a = .5, v.f1 =.5, v.f2 = .5, z = .1, sz = .1, sv = .3, t0 = .05)
pop.prior <- BuildPrior(
   dists = rep("tnorm", npar),
   p1    = pop.mean,
   p2    = pop.scale,
   lower = c(0, rep(-5, 2), rep(0, 4)),
   upper = c(5, rep( 7, 2), 1, 2, 1, 1))
```

As usual, I want to visually check if the assumed mechanism is reasonable.
```
plot(pop.prior)
```

![hpopprior]({{"/images/random-effect-model/hpopprior.png" | absolute_url}})


After making sure that the data generating mechanism is proper, I then
simulated a data set with 40 participants and 250 trials for each
condition.

```
dat <- simulate(model, p.prior = pop.prior, nsim = 250, nsub = 40)
dmi <- BindDataModel(dat, model)
ps  <- attr(dat, "parameters")
```

In the hierarchical case of the parameter recovery study, my aim
is to recover not only _ps_ matrix, but also the data generating
mechanism.  That is, I wish to be able to known _pop.mean_,
_pop.scale_ and their marginal distribution, as well as the _ps_.
A reminder _ps_ is a matrix, storing the true values for each
DDM parameter. Each row of the matrix represents the parameter
vector for a participant.

> dplyr::tbl_df(ps)


```
## A tibble: 40 x 7
##        a  v.f1  v.f2     z    sz    sv    t0
##    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
##  1  2.93  4.30  2.95 0.486 0.151 0.775 0.304
##  2  1.52  3.74  2.40 0.589 0.258 0.809 0.340
##  3  1.85  4.31  2.62 0.636 0.318 0.903 0.349
##  4  2.34  3.94  2.53 0.578 0.127 0.993 0.283
##  5  2.44  4.50  2.68 0.566 0.246 0.589 0.261
##  6  2.73  4.08  3.68 0.465 0.182 0.973 0.290
##  7  2.34  2.89  3.69 0.742 0.307 0.592 0.325
##  8  1.90  4.35  3.56 0.512 0.186 0.513 0.309
##  9  2.60  4.18  2.81 0.541 0.367 0.758 0.270
## 10  1.64  3.77  2.37 0.596 0.286 0.995 0.375
##  with 30 more rows
```

OK. The above is only preparation work for a parameter recovery study.
In the following, I will start to conduct Bayesian sampling to
draw samples from the posterior distribution, hoping that I
can recover _pop.mean_, _pop.scale_, the target distribution, and
the _ps_ matrix.

I already have the likelihood, which is the DDM equation (Ratcliff &
Tuerlinckx, 2002). I will need to set up my prior belief, namely
prior distributions for the seven DDM parameters. In the case of
hierarchical model, there are two set of prior distributions: one is
usually called hyper-prior distributions  and the other simply prior
distributions.  The former is my prior belief about the distributions
(_pp.prior_ below) accounted by _pop.mean_ and _pop.scale_. The latter 
is my prior belief about separate DDM mechanism for each individual
participant (_p.prior_ below).

```
p.prior <- BuildPrior(
  dists = rep("tnorm", npar),
  p1    = pop.mean,
  p2    = pop.scale*5,
  lower = c(0,-5, -5, rep(0, 4)),
  upper = c(5, 7,  7, 1, 2, 1, 1))
mu.prior <- BuildPrior(
  dists = rep("tnorm", npar),
  p1    = pop.mean,
  p2    = pop.scale*5,
  lower = c(0,-5, -5, rep(0, 4)),
  upper = c(5, 7,  7, 1, 2, 1, 1))
sigma.prior <- BuildPrior(
  dists = rep("beta", npar),
  p1    = rep(1, npar),
  p2    = rep(1, npar),
  upper = rep(2, npar))

names(sigma.prior) <- GetPNames(model)
```


A convention in _ggdmc_ is to bind location and scale prior distributions
as one list object. This is just for the convenience of data handling
in R, which is not so convenient in C++.
```
pp.prior <- list(mu.prior, sigma.prior)
```


Then, the following sampling procedure mostly will not return results
immediately. I will record the time to show, so you can know what to
expect.  The option, _debug = TRUE_, is to use the conventional
migration (Turner et al., 2013), which I do not recommend,
because it is biased.

```
## run the "?" to see the details of function options
?StartNewHypersamples
?run

hsam0 <- run(StartNewHypersamples(5e2, dmi, p.prior, pp.prior, 2),
             pm = .05, hpm = .05, debug = TRUE) ## 35 mins
hsam <- run(RestartHypersamples(5e2, hsam0, thin = 8),
            pm = 0, hpm = 0, debug = TRUE)      ## 150 mins
hsam <- run(RestartHypersamples(5e2, hsam0, thin = 16),
            pm = 0, hpm = 0, debug = TRUE)      ## 5 hrs
hsam <- run(RestartHypersamples(5e2, hsam0, thin = 32),
            pm = 0, hpm = 0, debug = TRUE)      ## 10 hrs
hsam <- run(RestartHypersamples(5e2, hsam0, thin = 64),
            pm = 0, hpm = 0, debug = TRUE)      ## 20.6 hrs
save(pop.mean, pop.scale, pop.prior, model, dat, dmi, npar, ps,
     hsam0, hsam, file = "data/hierarchical/ggdmc_4_7_DDM.rda")

## 4 rounds
thin <- 8
repeat {
     hsam <- run(RestartHypersamples(5e2, hsam, thin = thin),
                 pm = 0, hpm = 0, debug = TRUE)
     save(pop.mean, pop.scale, pop.prior, model, dat, dmi, npar, ps,
          hsam0, hsam, file = "data/hierarchical/ggdmc_4_7_DDM.rda")
     rhats <- hgelman(hsam)
     thin <- thin * 2
     if (all(rhats < 1.1) || counter > 1e2) break
}

save(pop.mean, pop.scale, pop.prior, model, dat, dmi, npar, ps,
  hsam0, hsam, file = "data/hierarchical/ggdmc_4_7_DDM.rda")
```

Similar to many standard modeling works, I must diagnose the
modeling process to check the posterior distribution is reliable. I
can check visually as well as calculating some statistics. First,
I conducted visually checks for the trace plots and posterior
distributions.

1. posterior log-likelihood at hyper level
2. hyper parameters
3. posterior log-likelihood at the data level
4. data level parameters for each participants
5. posterior distributions


```
plot(hsam, hyper = TRUE)
plot(hsam, hyper = TRUE, pll = FALSE)
rhat <- hgelman(hsam)
## Diagnosing theta for many participants separately
## Diagnosing the hyper parameters, phi
## hyper     1     2     3     4     5     6     7     8     9    10    11    12
##  1.02  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00
##    13    14    15    16    17    18    19    20    21    22    23    24    25
##  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00
##    26    27    28    29    30    31    32    33    34    35    36    37    38
##  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00
##    39    40
##  1.01  1.01
```
