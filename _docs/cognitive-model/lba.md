---
title: The Linear Ballistic Accumulation Model
category: Cognitive Model
order: 2
---

This lesson demonstrates how to control the "golem" (McElreath, 2016), the
canonical linear ballistic accumulation (LBA) model (Brown & Heathcote, 2008).
Please refer to the LBA paper for more details. Here I focused only on how 
to use this model in a practical Bayesian MCMC context.

Here I used an imaginary experiment with a design of one binary stimulus
factor (S), such as left vs. right motion random dots. In a later tutorial,
I will fit the model to a real world data set. The LBA model presumes
one latent matching (M) factor and an observable accumulator factor (R),
corresponding to responses. For most beginners to learn this model, these
two factors are easily to get confused.

> match.map = list(M = list(left = "LEFT", right = "RIGHT")),

> responses = c("LEFT", "RIGHT"),

Note again I differentiate uppercase and lowercase letters. So in a 
data frame (a terminology of R language), there will be two columns, storing
the S and R factors:

```
dplyr::tbl_df(dat1)
## # A tibble: 32,768 x 3
##      S     R      RT
##    <fct> <fct> <dbl>
##  1 left  LEFT  0.209
##  2 left  RIGHT 0.384
##  3 left  LEFT  1.30 
##  4 left  LEFT  0.322
##  5 left  LEFT  0.219
##  6 left  LEFT  0.473
##  7 left  LEFT  0.247
##  8 left  LEFT  0.213
##  9 left  RIGHT 0.451
## 10 left  LEFT  0.391
## # ... with 32,758 more rows
```

So "left" and "LFET" mean the random dots moving left and a left
response. From an experimenter's perspective, this imaginary
experiment only has one stimulus (S) factor, which has two levels,
random dots moving towards right and moving towards left as defined below.

> factors = list(S = c("left", "right")),

```
model <- BuildModel(p.map = list(A = "1", B = "1", t0 = "1", mean_v = "M",
                                 sd_v = "M", st0 = "1"),
  constants = c(st0 = 0, sd_v.false = 1, mean_v.false = 0),
  match.map = list(M = list(left = "LEFT", right = "RIGHT")),
  factors   = list(S = c("left", "right")),
  responses = c("LEFT", "RIGHT"),
  type      = "norm")
```

The first option in the _BuildModel_ function indicates the experimental
design. In this example, I assumed the S factor does not affect any
cognitive operations, presumed by the LBA model. Therefore, I entered
_p.map_ as:

> p.map = list(A = "1", B = "1", t0 = "1", mean_v = "M",
>              sd_v = "M", st0 = "1"),

The notations of the parameters in the LBA model refer to:

1. **A**, the variability of the starting point,
2. **B**, the travelling distance of accumulators,
3. **b**, (not shown in the _p.map_) the decision threshold,
4. **t0**, the non-decision time
5. **mean_v**, the means of the drift rate,
6. **sd_v**, the standard deviation of the drift rate,
7. **st0**, the variability of the non-decision time component.

The **A = "1"**, for instance, indicates that the variability of the
starting point is modelled against only the intercept, _1_. The _M_
factor, because it is defined by the LBA model as latent factor, you
still see it in the p.map. It indicates there are two means,
**mean_v** of the
drift rates, one for each accumulator: the accumulator for the
correct / matched responses and the accumulator for the error /
mismatched responses. Similarly, this is applied on the standard
deviation of the drift rate, **sd_v**, too.

The only effect in the model defined by the _p.map_ is that the
drift rate for a correct response is larger than that for an
error response. This is an assumption based on, in general,
psychological literature.  This is artificially set at

> constants = c(st0 = 0, sd_v.false = 1, mean_v.false = 0),

, which enforces **mean_v.false = 0**. This is to presume
(also frequent observed phenomenon) that manifested
accuracy rate should usually be greater than chance (50%).

**mean_v.false** stands for the mean of the drift rate
of the error (false) accumulator. Because it is always zero,
the correct drift rate, **mean_v.true**, drawn from a truncated
normal distribution bounded by 0 and Inf, will always be larger
than the error drift rate.

### Demo 1
1. Fast and error prone performance
This demonstration shows how I controlled the LBA golem to
simulate fast and error prone choice RT data. I defined a
true parameter vector, defining **sd_v.true** = (0.66),
which is greater than **sd_v.false** = 1.  This seems
often seen in empirical data.


```
pvec1 <- c(A = 1, B = 0, t0 = .2, mean_v.true = 1, sd_v.true = 0.66)
dat1  <- simulate(model, ps = pvec1, nsim = 16384), model)
dmi1  <- BindDataModel(dat1, model)
```

In the following, I used functions in _dplyr_ to
print out the mean response times and accuracy for each
stimulus types. The results showed:

1. Error and correct responses have similar average RTs.
2. Stimulus type 1 and stimulus type 2 have similar rates
of correctness.

```
library(dplyr)
correct <- dmi1$S == tolower(dmi1$R)
d <- dplyr::tbl_df(dat1)
group_by(d, S) %>% summarize(m = mean(RT))
## A tibble: 2 x 2
##   S         m
##   <fct> <dbl>
## 1 left  0.628
## 2 right 0.620

```
