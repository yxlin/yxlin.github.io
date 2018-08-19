---
title: The Linear Ballistic Accumulation Model
category: Cognitive Model
order: 2
---

This lesson demonstrates how to control the "golem" (McElreath, 2016), the
canonical linear ballistic accumulation (LBA) model (Brown & Heathcote, 2008).
Please refer to the above LBA paper for more details. Here I focus only on 
how to use this model in the Bayesian MCMC context.

The LBA model posits a latent matching (M) factor and a response factor (R)
on top of regular experimental factors. For most people who are not familiar
with the LBA model, the two factors are unfortunately
confusing.

Also for the modelling technicalities, the LBA model must fix one of the
parameters in the mean_v or sd_v in at least one design cell. This is to
serve as scaling purpose, similar to the moment-to-moment variability
in the decision diffusion model. For example, the following code fixes
sd_v = 1.

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
```


In the above model, I define only one experimental factor, S, for stimulus, which
has two levels, s1 and s2. The accuracy, reflected by the M factor, is mapped
by _s1 = 1_ and _s2 = 2_, meaning that a correct response for s1 (or s2) stimulus
is response r1 (or r2) and an error response for s1 (or s2) stimulus is
r2 (or r1). Below I use _simulate_ to generate an example data set.

```
p.vector <- c(A = .75, B = 1.25, t0 = .15, mean_v.true = 2.5, mean_v.false = 1.5)
dat <- simulate(model, nsim = 30, ps = p.vector)
dmi <- BuildDMI(dat, model)  ## DMI stands for data model instance.

dplyr::tbl_df(dmi)
# A tibble: 60 x 3
##    S     R        RT
##    <fct> <fct> <dbl>
##  1 s1    r1    0.608
##  2 s1    r1    0.972
##  3 s1    r2    0.817
##  4 s1    r1    0.718
##  5 s1    r1    0.618
##  6 s1    r1    1.17 
##  7 s1    r1    0.730
##  8 s1    r2    0.727
##  9 s1    r1    0.711
## 10 s1    r1    0.688
```

I use an imaginary experiment with a design of one binary stimulus
factor (S), such as left vs. right motion random dots. 

> match.map = list(M = list(left = "LEFT", right = "RIGHT")),
> responses = c("LEFT", "RIGHT"),

In another tutorial, I will fit the model to an empirical data
set ([Cox & Criss, 2017](https:/osf.io/uhejm/)) to demonstrate fitting
HLBA model.

The above _match.map_ code shows the usage of strings, instead of numbers.
The "left" and "LFET" could mean the random dots moving left and a left
response. From an experimenter's perspective, this imaginary experiment
only has one stimulus (S) factor, which has two levels,
random dots moving towards right and moving towards left as defined below.

> factors = list(S = c("left", "right")),

Below is the complete model definition.

```
model <- BuildModel(p.map = list(A = "1", B = "1", t0 = "1", mean_v = "M",
                                 sd_v = "M", st0 = "1"),
  constants = c(st0 = 0, sd_v.false = 1, mean_v.false = 0),
  match.map = list(M = list(left = "LEFT", right = "RIGHT")),
  factors   = list(S = c("left", "right")),
  responses = c("LEFT", "RIGHT"),
  type      = "norm")
```

The first option in the _BuildModel_ function, _p.map_ indicates the
experimental design. In this example, I assumed the S factor does not affect
any LBA latent variables operations. Therefore, I entered _p.map_ as:

> p.map = list(A = "1", B = "1", t0 = "1", mean_v = "M",
>              sd_v = "M", st0 = "1"),



The notations of the parameters in the LBA model refer to:

1. **A**, the variability of the starting point,
2. **B**, the travelling distance of accumulators,
3. **b**, (not shown in the _p.map_) the decision threshold,
4. **t0**, the non-decision time
5. **mean_v**, the means of the drift rates,
6. **sd_v**, the standard deviations of the drift rates,
7. **st0**, the variability of the non-decision time component.

The **A = "1"**, for instance, indicates that the variability of the
starting point is fit by the intercept, _1_. The _M_
factor, because it is defined by the LBA model as a latent factor, 
you still see it in the p.map. It indicates there are two drift rate
means in **mean_v**, one for each accumulator: the accumulator for the
correct / matched responses and the accumulator for the error /
mismatched responses. Similarly, this is also applied to  the standard
deviation of the drift rates, **sd_v**.

The only effect in the model defined in the _p.map_ is that the
drift rate for a correct response is larger than that for an
error response. This is an assumption based on, in general,
psychological literature.  This is artificially set at

> constants = c(st0 = 0, sd_v.false = 1, mean_v.false = 0),

which enforces **mean_v.false = 0**. This is to presume
(also frequent observed phenomenon) that manifested
accuracy rate should usually be greater than chance (50%).

**mean_v.false** stands for the mean of the drift rate
of the error (false) accumulator. Because it is always zero,
the correct drift rate, **mean_v.true**, if drawn from a
truncated normal distribution bounded by 0 and Inf, will
always be larger than the error drift rate.

### Demo 1
1. Fast and error prone performance
This demonstration shows how I control the LBA golem to
simulate fast and error prone RT distributions. I defined a
true parameter vector, defining **sd_v.true** = (0.66),
which is smaller than **sd_v.false** = 1.  This seems
often seen in empirical data.

```
pvec1 <- c(A = 1, B = 0, t0 = .2, mean_v.true = 1, sd_v.true = 0.66)
dat1  <- simulate(model, ps = pvec1, nsim = 1e4)
dmi1  <- BuildDMI(dat1, model)
```

In the following, I used functions in _dplyr_ to
print out the mean response times and accuracy for each
stimulus types. The results showed:

1. Error and correct responses have similar average RTs.
2. Stimulus type 1 and stimulus type 2 have similar rates
of correctness.

```
library(dplyr)

## dplyr
library(dplyr)
dat1$C <- dat1$S == tolower(dat1$R)
d <- dplyr::tbl_df(dat1)

## Print average RTs and accuracy rates for each condition
group_by(d, S, C) %>% summarize(m = mean(RT))
## A tibble: 4 x 3
## Groups:   S [?]
##   S     C         m
##   <fct> <lgl> <dbl>
## 1 left  FALSE 0.624
## 2 left  TRUE  0.645
## 3 right FALSE 0.639
## 4 right TRUE  0.634

group_by(d, S, C) %>% summarize(m = length(RT) / 1e4)
## A tibble: 4 x 3
## Groups:   S [?]
##   S     C         m
##   <fct> <lgl> <dbl>
## 1 left  FALSE 0.391
## 2 left  TRUE  0.609
## 3 right FALSE 0.392
## 4 right TRUE  0.608

## data.table
library(data.table)
DT <- data.table(dat1)

## Print average RTs and accuracy for each condition
DT[, .(MRT = round(mean(RT), 3)), .(S, C)]
##        S     C   MRT
## 1:  left  TRUE 0.645
## 2:  left FALSE 0.624
## 3: right  TRUE 0.634
## 4: right FALSE 0.639

prop <- DT[, .N, .(S, C)]
prop[, NN := sum(N), .(S)]
prop[, acc := round(N/NN, 2)]
## Print accuracy rates for each condition
prop

##        S     C    N    NN  acc
## 1:  left  TRUE 6092 10000 0.61
## 2:  left FALSE 3908 10000 0.39
## 3: right  TRUE 6079 10000 0.61
## 4: right FALSE 3921 10000 0.39
```

