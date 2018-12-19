---
title: Maximising Likelihoods
category: Modelling Basics
order: 6
---

This is a short note for one method to conduct
maximum likelihood estimation (MLE) to fit the LBA model. 

In essence, the MLE is not a very difficult statistical technique,
but there are some trivialities regarding to the cognitive model
and its influence on the usage of optimiser that must be addressed.
Otherwise, you would not recover the parameters in the LBA model (or
cognitive models in general).

In short, you must adjust either the objective function, the processing
of data preparation, or how to propose parameters according to a
specific cognitive model.  For example, the non-decision time must not go
below 0 second. If you do not (or cannot) add this constraint on
the optimiser (e.g., the R function, _optim_), the resulting
fit may not converge or the estimates (even converged)
will be unreasonable, psychologically speaking.

Below I use _ggdmc_ to conduct a simulation study to demonstrate the point.

## Simulation study

Firstly, as usual, I use the BuildModel function to set up a null model
with only a stimulus factor (denoted _S_).  That is, the model parameters
do not associate with any factors.

Next I arbitrarily set up a true parameter vector, _p.vector_, and request 100
trials per condition. My aim is to recover the true parameters.

```
require(ggdmc)
model <- BuildModel(
  p.map     = list(A = "1", B = "1", t0 = "1", mean_v = "M", sd_v = "1",
                   st0 = "1"),
  match.map = list(M = list(s1 = 1, s2 = 2)),
  factors   = list(S = c("s1", "s2")),
  constants = c(st0 = 0, sd_v = 1),
  responses = c("r1", "r2"),
  type      = "norm")

p.vector <- c(A = .75, B = 1.25, t0 = .15, mean_v.true = 2.5, mean_v.false = 1.5)
ntrial <- 1e2

## use the seed option to make sure I always replicate the result
## remove it, if you want to see the stochastic process.
dat <- simulate(model, nsim = ntrial, ps = p.vector, seed = 123)
dmi <- BuildDMI(dat, model)
```


## Description statistics
As a good practice, we would mostly like to check basic descriptive
statistics.  First let's see the RT distributions.

Note there are two histograms (i.e., distributions). This is one of
the specifics in the choice RT models. This is sometimes dubbed defective
distributions, meaning multiple distributions composing a complete model
(integrated to 1).

The _likelihood_norm_ function in the _ggdmc_ has considered this,
so you will not see how the internal C++ codes handle this triviality.
But if you use the early LBA density function, say "ggdmc:::n1PDFfixedt0"
(meaning node 1 probability density function), "ggdmc:::fptcdf" or
"ggdmc:::fptpdf", you need to handle the calculation of
"defective distributions" accordingly.

![mle_data]({{"/images/basics/mle_data.png" | relative_url}})


```
dmi$C <- ifelse(dmi$S == "s1" & dmi$R == "r1", TRUE,
         ifelse(dmi$S == "s2" & dmi$R == "r2", TRUE,
         ifelse(dmi$S == "s1" & dmi$R == "r2" ,FALSE,
         ifelse(dmi$S == "s2" & dmi$R == "r1", FALSE, NA))))
					 
prop.table(table(dmi$C))
## FALSE == error responses (25.5%)
## TRUE == correct responses (74.5%)
## FALSE  TRUE 
## 0.255 0.745

## The maximum (log) likelihoods
den <- likelihood_norm(p.vector, dmi)
sum(log(den))
## [1] -112.7387

```

The following is the objective function.  Note _data_ must be
a data model instance. This requirement is to use _ggdmc_
internal to handle many trivialities, for instance, the defective
distributions, experimental design, transforming parameter
($$b = A + B$$).  If you use the bare density function (e.g., n1PDF),
you must handle these trivialities. Also I use negative log likelihood.

```
objective_fun <- function(par, data) {
  den <- likelihood_norm(par, data)
  return(-sum(log(den)))
}
```

> init_par[3] <- runif(1, 0, min(dmi$RT))

This line makes starting _t0_ not less than the minimal RT in
the data. This is another psychological consideration. It may help.
However, it does not guarantee the optimiser won't propose a _t0_
less than minimal RT in the data.

```
init_par <- runif(5)
init_par[3] <- runif(1, 0, min(dmi$RT)) 
names(init_par) <- c("A", "B", "t0", "mean_v.true", "mean_v.false")
res <- nlminb(objective_fun, start = init_par, data = dmi, lower = 0)
round(res$par, 2)  ## remember to check res$convergence
```

Below is a list of possible recovered values. The last line show
the true parameter vector for comparison. The first column shows
the numbers of trial per condition.  At the size of 1e5, the
recovered values almost equal to the true values.

```
##         A       B      t0 mean_v1 mean_v2
## 1e2  0.79    0.98    0.17   2.26     0.77
## 1e2  0.86    1.74    0.04   2.80     1.82 
## 1e2  0.91    0.67    0.28   2.04     1.02 
## 1e2  0.72    1.36    0.14   2.74     1.60 
## 1e3  0.71    1.15    0.16   2.32     1.40 
## 1e3  0.61    1.63    0.08   2.70     1.76
## 1e4  0.71    1.28    0.15   2.51     1.50 
## 1e5  0.75    1.24    0.15   2.49     1.49 
## true 0.75    1.25    0.15   2.50     1.50

```

Instead of using the _optim_ function, I opt to _nlminb_
function.  This is again a model specific consideration. In
the LBA model, A, B, and t0 must not be less than 0, so it
will help if we can impose this constraint. Both _optim_ and _nlminb_ offer
an argument, _lower_, to constraint the parameter proposals.
However, if you impose the _lower_ constraint, _optim_ allows
only (?) the optimisation method, "L-BFGS-B", which does
not handle infinite values. Unfortunately, in fitting the
LBA model, it is likely a parameter proposal would result in
an infinite log-likelihood.


## Bonus

A better way to initialise a parameter proposal is to use prior
distribution.  rprior in ggdmc allows you to do this.

```
p.prior <- BuildPrior(
  dists = c("tnorm", "tnorm", "beta", "tnorm", "tnorm"),
  p1    = c(A = 1, B = 1, t0 = 1, mean_v.true = 1, mean_v.false = 1),
  p2    = c(1,  1,  1, 1, 1),
  lower = c(rep(0, 3),  rep(NA, 2)),  
  upper = c(rep(NA, 2), 1, rep(NA, 2)))
  
init_par <- rprior(p.prior)
##            A            B           t0  mean_v.true mean_v.false 
##         0.40         0.65         0.24         0.89        -0.26 

```

