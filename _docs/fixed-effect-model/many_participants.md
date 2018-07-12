---
title: Multiple Participants
category: Fixed Effects Model
order: 2
---

In this tutorial, I illustrated fitting multiple participants, assuming
the mechanism of data generation is fixed-effect models. That is, each
of the participants are accounted for by their separate mechanisms. I also
assume the LBA model is the mechanism generating the choice RT data.

I made up a two-factor factorial design. The first two-level factor is
the stimulus (S). Suppose the stimuli have two types: one is low quality
face photos, so people find it hard to recognize and the other
is normal quality face photo.  The second factor is the frequency (F),
supposing one type is the celebrity photos, so people perhaps see more often, 
and the other is the photos of randomly selected strangers.

In the model setting, I presume a rate model, which has its drift rates
affected by the two factors, S and F.  The latent factor, _M_, is just a
LBA way to model independent accumulators. Another factor, _R_, not
explicitly in the factorial design, is an indicator factor, indicating
the response type affecting the threshold parameter (i.e., accumulators
traveling distance).

```
model <- BuildModel(
          p.map     = list(A = "1", B = "R", t0 = "1",
            mean_v = c("S", "F", "M"), sd_v = "M", st0 = "1"),
          match.map = list(M = list(s1 = 1, s2 = 2)),
          factors   = list(S = c("s1", "s2"), F = c("f1", "f2")),
          constants = c(sd_v.false = 1, st0 = 0),
          responses = c("r1", "r2"),
          type      = "norm")
##  [1] "A"                  "B.r1"               "B.r2"              
##  [4] "t0"                 "mean_v.s1.f1.true"  "mean_v.s2.f1.true" 
##  [7] "mean_v.s1.f2.true"  "mean_v.s2.f2.true"  "mean_v.s1.f1.false"
## [10] "mean_v.s2.f1.false" "mean_v.s1.f2.false" "mean_v.s2.f2.false"
## [13] "sd_v.true"         
npar <- length(GetPNames(model))
```

To simulate many participants, I set up a population distribution, which
is a bit of in conflict with the assumption of fixed-effects model. That is,
this way to generate data is to presume that a random-effects model at
work. For the purpose of illustration, I forgo this issue for now.

```
pop.mean <- c(A = .4, B.r1 = .85, B.r2 = .8, t0 = .1,
              mean_v.s1.f1.true = 2.5,    mean_v.s2.f1.true = 3.5,
              mean_v.s1.f2.true = 4.5,    mean_v.s2.f2.true = 5.5,
              mean_v.s1.f1.false = 1.00,  mean_v.s2.f1.false = 1.10,
              mean_v.s1.f2.false = 1.05,  mean_v.s2.f2.false = 1.20,
              sd_v.true = .25)
pop.scale <- c(A = .1, B.r1 = .1, B.r2 = .1, t0 = .05,
              mean_v.s1.f1.true = .2,   mean_v.s2.f1.true = .2,
              mean_v.s1.f2.true = .2,   mean_v.s2.f2.true = .2,
              mean_v.s1.f1.false = .2,  mean_v.s2.f1.false = .2,
              mean_v.s1.f2.false = .2,  mean_v.s2.f2.false = .2,
              sd_v.true = .1)

pop.prior <- BuildPrior(
  dists = rep("tnorm", npar),
  p1    = pop.mean,
  p2    = pop.scale,
  lower = c(rep(0, 4), rep(NA, 8), 0),
  upper = c(rep(NA, npar)))

```


You may want to visually check how the prior distributions look like.
_ggdmc_ has a _plot_ function to do just that. Note you need to load _ggdmc_
package (i.e., _require(ggdmc)_) to make _plot_ function polymorphic .

```
plot(pop.prior)

```

![popprior]({{"/images/fixed-effect-model/popprior.png" | relative_url}})


```
## Simulate some data
dat <- simulate(model, nsim = 250, nsub = 20, p.prior = pop.prior)
dmi <- BindDataModel(dat, model)
dplyr::tbl_df(dat)
## A tibble: 20,000 x 5
##    s     S     F     R        RT
##    <fct> <fct> <fct> <fct> <dbl>
##  1 1     s1    f1    r1    0.561
##  2 1     s1    f1    r1    0.438
##  3 1     s1    f1    r1    0.568
##  4 1     s1    f1    r2    0.431
##  5 1     s1    f1    r1    0.433
##  6 1     s1    f1    r1    0.577
##  7 1     s1    f1    r1    0.548
##  8 1     s1    f1    r1    0.569
##  9 1     s1    f1    r1    0.532
## 10 1     s1    f1    r1    0.513
## ... with 19,990 more rows


```

The true parameter vectors, which were randomly chosen from _pop.prior_, can
be retrieved by looking up the **parameters** attribute, attached onto the
_dat_ object.

```
require(matrixStats)
ps <- attr(dat, "parameters")
mu <- round(colMeans2(ps), 2)
sigma <- round(colSds(ps), 2)
truevalues <- rbind(mu, sigma)
colnames(truevalues) <- GetPNames(model)
##       A B.r1 B.r2   t0 mean_v.s1.f1.true mean_v.s2.f1.true mean_v.s1.f2.true
## mu 0.41 0.82 0.77 0.10              2.49              3.56              4.50
## si 0.11 0.10 0.09 0.05              0.21              0.19              0.22
##    mean_v.s2.f2.true mean_v.s1.f1.false mean_v.s2.f1.false mean_v.s1.f2.false
## mu              5.49               1.03               1.15               1.08
## si              0.22               0.15               0.23               0.15
##    mean_v.s2.f2.false sd_v.true
## mu               1.11      0.24
## si               0.16      0.10
```

Now I am ready to fit the twenty participants. Ideally, I wish to
fit them with twenty CPU cores, so that would be quicker to finish
the job. But here I have only a twelve-core machine, so I will fit ten
participants independently for two runs.

Note that I set the _ncore_ option as 10, indicating that I will launch
ten separate R processes (at the R level).  In a later tutorial, 
the solution of multiple core process (i.e., OpenMP at the C++ level) is
different from the R solution of multiple core, because of the different
data structure between the hierarchical and single-level models.

Fitting 10 participants will take a while, so I saved the
data at two stages.

```
## Sampling -------------
p.prior <- BuildPrior(
  dists = rep("tnorm", npar),
  p1    = pop.mean,
  p2    = pop.scale*20,
  lower = c(rep(0, 4), rep(NA, 8), 0),
  upper = c(rep(NA, npar)))
plot(p.prior)  ## visual check the prior distributions

thin <- 32
sam <- run(StartManynewsamples(5e2, dmi, p.prior, thin),
           ncore = 10, pm = .20)
save(sam, thin, model, npar, pop.prior, data, dmi, ps, truevalues,
     p.prior, file = "data/ggdmc_4_5_LBA_analytic.rda")
sam <- run(RestartManysamples(5e2, sam, thin),
           ncore = 10, pm = .20)
save(sam, thin, model, npar, pop.prior, data, dmi, ps, truevalues,
     p.prior, file = "data/ggdmc_4_5_LBA_analytic.rda")
```

DE-MCMC is inefficient, comparing to distributed genetic algorithm, in
handling a complex model with many parameters (> 10). The model here is
at the level of 13 parameter.  I expected that I will encounter
some difficult parameter spaces, so I used a simple way to circumvent
this challenge to search the hard parameter spaces. That is, I used
R's _repeat_ function to iterate the model fitting. The below code
checks multivariate potential scale reduction factor (_mpsrf_,
Brooks & Gelman, 1998), and finished the fit only when _mpsrt_ is
less than 1.1.

```
repeat {
   sam <- run(RestartManysamples(5e2, sam, thin),
           ncore = 10, pm = .20)
   save(sam, thin, model, npar, pop.prior, data, dmi, ps, truevalues,
       p.prior, file = "data/ggdmc_4_5_LBA_analytic.rda")
   rhats <- gelman(sam) 
   if (all(unlist(lapply(rhats, function(x) x[[2]])) < 1.1)) break
}

```

As always, I need to check if the model fit converged.  I used _plot_ to
visually check if posterior log-likelihood converged.

> plot(sam)

![traceplots]({{"/images/fixed-effect-model/many-subjects.png" | relative_url}})

_gelman_ function will print the potential scale reduction
factor (psrf). If psrf is less than 1.1 or a mores conservative
criterion, 1.05, it suggests that chains are well-mixed. This is a bit
of redundant, because my automatic routine had made certain that the fit
will return psrf's less than 1.1.

```
gelman(sam)
# Diagnosing theta for many participants separately
#   15   20   13   18    6   17   12   19    5   11    8    3   16   14    1    2    9
# 1.01 1.01 1.01 1.01 1.01 1.01 1.01 1.01 1.01 1.01 1.01 1.01 1.01 1.01 1.01 1.02 1.02
#    4    7   10
# 1.02 1.03 1.03
# Mean
# [1] 1.01
```


By setting the option, _pll_, which stands for posterior log-likelihood,
to FALSE and the option, _den_, which stands for density plot, to TRUE , you
can check the trace plots for each model parameters. Because there are
twenty participants, it will be difficult to see figures clearly.  I
plotted them separately in a pdf file to check it. Here showed the posterior
density plots for one of the participants. Note that because there are
a lot of data, this would be, perhaps, 100s MB pdf file.

```
pdf("figs/subjects-density.pdf")
lapply(sam, ggdmc:::plot.model, pll = FALSE, den = TRUE )
dev.off()
```

![densityplots]({{"/images/fixed-effect-model/subject1-density.png" | relative_url}})


One specific feature in _ggdmc_ is that it uses pMCMC, so occasionally,
we want to check a subset of chains. The function will randomly pick three chains
to plot

> plot(sam, subchain = TRUE)

![subchains1]({{"/images/fixed-effect-model/subchain1.png" | relative_url}})

You can indicate how many subset of chains to plot, too.

> plot(sam, subchain = TRUE, nsubchain = 4))

![subchains2]({{"/images/fixed-effect-model/subchain2.png" | relative_url}})

You can also indicate which chains, instead of randomly selecting a subset of chains.

> plot(sam, subchain = TRUE, nsubchain = 4, chains = c(1:3))

![subchains3]({{"/images/fixed-effect-model/subchain3.png" | relative_url}})


These are a lot of checks! Finally and fortunately, because this is a parameter recovery study,
I can look up the true parameters to see if I do estimate them well. _summary_ function will
do the trick by entering TRUE for the _recovery_ option and entering the true parameter matrix,
which I had stored it to a _ps_ object before, to _ps_ option.

> est <- summary(sam, recovery = TRUE, ps = ps)

```
# Summary each participant separately
#          A  B.r1  B.r2    t0 mean_v.s1.f1.true mean_v.s2.f1.true mean_v.s1.f2.true
# Mean  0.50  1.02  0.96  0.10              3.05              4.34              5.50
# True  0.41  0.82  0.77  0.10              2.49              3.56              4.50
# Diff -0.09 -0.20 -0.19  0.00             -0.56             -0.78             -1.00

# Sd    0.15  0.20  0.17  0.05              0.49              0.44              0.76
# True  0.11  0.10  0.09  0.05              0.21              0.19              0.22
# Diff -0.04 -0.10 -0.08 -0.01             -0.28             -0.25             -0.54
#      mean_v.s2.f2.true mean_v.s1.f1.false mean_v.s2.f1.false mean_v.s1.f2.false
# Mean              6.69               1.59               1.58               0.70
# True              5.49               1.03               1.15               1.08
# Diff             -1.20              -0.56              -0.43               0.38

# Sd                0.82               0.34               1.21               1.58
# True              0.22               0.15               0.23               0.15
# Diff             -0.59              -0.19              -0.98              -1.43
#      mean_v.s2.f2.false sd_v.true
# Mean              -0.38      0.30
# True               1.11      0.24
# Diff               1.48     -0.06

# Sd                 1.23      0.11
# True               0.16      0.10
# Diff              -1.07     -0.01
```

