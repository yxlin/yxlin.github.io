---
title: Descriptive Statistics
category: Modelling Basics
order: 3
---

In most RT modelling work, researchers usually want to examine the manifested
statistics.  Often, these are the average response times (RTs) and accuracy rates.
In the following, I used a model not yet fully implemented here,
LNR (Heathcote & Love, 2012), as an example to illustrate a method in _R_ to
calculate these statistics efficiently. The user wishes to understand and
apply LNR model on her / his work can find useful information in the DMC tutorials
(Heathcote et al., 2018). Because LNR is not computationally intensive, I
have yet fully implemented it here.

This LNR model presumes one stimulus (S) factor, and similar to the LBA model, it
has a latent matching (M) factor.


```
library(data.table); library(ggdmc)

model <- BuildModel(
  p.map     = list(meanlog = "M", sdlog = "M", t0 = "1", st0 = "1"),
  match.map = list(M = list(left = "LEFT", right = "RIGHT")),
  factors   = list(S = c("left", "right")),
  responses = c("LEFT", "RIGHT"),
  constants = c(st0 = 0),
  type      = "lnr")
```


The arbitrary chosen true parameters generate a reasonable RT distribution,
which similar with typical choice RT data, giving approximately 25% errors
(I will show you this later).

```
p.vector <- c(meanlog.true = -1, meanlog.false = 0, sdlog.true = 1,
              sdlog.false = 1, t0 = .2)
```

_simulate_ function takes the first option, _model_ to generate data
based on the provided model. _ps_ option expects a true parameter vector that
matches the setting in the model object, _nsim_ option expects the number of
trial per condition.

```
dat <- simulate(model, ps = p.vector, nsim = 1024)
d <- data.table(dat)
##           S     R        RT
##    1:  left  LEFT 0.3821405
##    2:  left  LEFT 0.7859101
##    3:  left  LEFT 0.5237262
##    4:  left RIGHT 0.3932804
##    5:  left  LEFT 0.6604592
##   ---                      
## 2044: right RIGHT 0.7342084
## 2045: right RIGHT 1.3628130
## 2046: right RIGHT 0.3343844
## 2047: right RIGHT 0.4913930
## 2048: right RIGHT 0.6119065
```
- S is the stimulus factor
- R is the response type
- RT stores response time in second

By using  _data.table_ function **.N**, I confirmed that each condition
does has 1024 trials.

> d[, .N, .(S)]
```
##        S    N
## 1:  left 1024
## 2: right 1024
```

A similar syntax, with S and R factors, I printed out the information
regarding the hit, correct rejection, false alarm and miss responses.
> d[, .N, .(S, R)]
```
##        S     R   N  ## assuming the left is signal and right is noise
## 1:  left  LEFT 791  ## hit
## 2:  left RIGHT 233  ## miss
## 3: right RIGHT 786  ## correct rejection
## 4: right  LEFT 238  ## false alarm
```

I used a ifelse chain to calculate a C column to indicate correct (TRUE)
and error (FALSE) responses. In real world data, there would be some
responses missing or participants pressing wrong keys, so the last else
is "NA" to catch these situations.

```
d$C <- ifelse(d$S == "left"  & d$R == "LEFT",  TRUE,
       ifelse(d$S == "right" & d$R == "RIGHT", TRUE,
       ifelse(d$S == "left"  & d$R == "RIGHT", FALSE,
       ifelse(d$S == "right" & d$R == "LEFT",  FALSE, NA))))
```

The data table now looks like below.
```
##           S     R        RT     C
##    1:  left  LEFT 0.3821405  TRUE
##    2:  left  LEFT 0.7859101  TRUE
##    3:  left  LEFT 0.5237262  TRUE
##    4:  left RIGHT 0.3932804 FALSE
##    5:  left  LEFT 0.6604592  TRUE
##   ---                            
## 2044: right RIGHT 0.7342084  TRUE
## 2045: right RIGHT 1.3628130  TRUE
## 2046: right RIGHT 0.3343844  TRUE
## 2047: right RIGHT 0.4913930  TRUE
## 2048: right RIGHT 0.6119065  TRUE
```


This is one way to calculate average RTs with data.table.
```
d[, .(MRT = round(mean(RT), 2)), .(C)]
##        C  MRT
## 1:  TRUE 0.61
## 2: FALSE 0.71
```

The syntax to calculate the response proportions, namely correct and
error rates, are less straightforward, but possible. Firstly, I
calculated the counts for hit, correct rejection, miss, and false
alarm and store them in _prop_. Then I made up a new column, called _NN_, to store
the total number of trial. Lastly, I divided the four conditions by
the total number of trial. I also used a _round_ to print only to the
two decimal place below zero.

```
prop <- d[, .N, .(S, R)]
prop[, NN := sum(N), .(S)]
prop[, acc := round(N/NN, 2)]
prop
##        S     R   N   NN  acc
## 1:  left  LEFT 791 1024 0.77
## 2:  left RIGHT 233 1024 0.23
## 3: right RIGHT 786 1024 0.77
## 4: right  LEFT 238 1024 0.23
```

## To be continue ...

## Reference
Heathcote A., and Love J. (2012) Linear deterministic accumulator models of simple choice.
frontiers in Psychology, 23. https://doi.org/10.3389/fpsyg.2012.00292.
