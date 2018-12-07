---
title: Random effect logistic regression
category: BUGS Examples Volumn 1
order: 1
---

Disclaimer: This tutorial uses an experimental (beta) version of _ggdmc_, which 
has added the functionality of fitting logistic regression models.  The software 
can be found in its GitHub. This document has yet completed.

The aim of tutorial is to document one method to fit the logistic regression 
model, using the [Seeds data](http://www.openbugs.net/Examples/Seeds.html).
Seeds data were studied in Crowder (1978), re-analysed by Breslow and Clayton (1993)
and used in the BUGS examples volumn I. This document expands the scope of ggdmc
to the logistic regression model.

I first convert the data to data frame.
```
rm(list = ls())
library(data.table); library(boot)
## Load Seeds data ------------
## 2 x 2 design
setwd("~/BUGS_Examples/vol1/Seeds/")
dat <- list(S = c(10, 23, 23, 26, 17,  5, 53, 55, 32, 46,
                  10,  8, 10,  8, 23,  0,  3, 22, 15, 32,
                  3),
            N = c(39, 62, 81, 51, 39,  6, 74, 72, 51, 79,
                  13, 16, 30, 28, 45,  4, 12, 41, 30, 51,
                  7),
            ## seed variety; 0 = aegytpiao 75 1 = aegyptiao 73
            X1 = c(0, 0, 0, 0, 0,  0, 0, 0, 0, 0,
                   0, 1, 1, 1, 1,  1, 1, 1, 1, 1,
                   1),
            ## root extract; 0 = bean; 1 = cucumber
            X2 = c(0, 0, 0, 0, 0,  1, 1, 1, 1, 1,
                   1, 0, 0, 0, 0,  0, 1, 1, 1, 1,
                   1),
            N = 21)

d <- data.table(S = dat$S, N = dat$N, P = dat$S/dat$N, X1= dat$X1, X2 = dat$X2)
dplyr::tbl_df(d)
## A tibble: 21 x 5  ## N = 21 (plates)
##        S     N     P    X1    X2
##    <dbl> <dbl> <dbl> <dbl> <dbl>
##  1    10    39 0.256     0     0
##  2    23    62 0.371     0     0
##  3    23    81 0.284     0     0
##  4    26    51 0.510     0     0
##  5    17    39 0.436     0     0
##  6     5     6 0.833     0     1
##  7    53    74 0.716     0     1
##  8    55    72 0.764     0     1
##  9    32    51 0.627     0     1
## 10    46    79 0.582     0     1
## ... with 11 more rows
```
* _S_, the number of (successfully) germinated seeds on the ith plate (i = 1, ... N);
* _N_, the number of total seeds on the ith plate;
* _P_, the proportion of germinated seeds; 
* _X1_, a two-level seed factor, aegyptiao 75 vs. aegyptiao 73;
* _X2_, a two-level root extract factor, bean vs. cucumber.

![seeds]({{"/images/BUGS/seeds/data.png" | relative_url}})

The interaction plot shows that the root extract type, cucumber, has a drastic
increase in successful germination when the seed type is aegyptiao 75, comparing to
when the seed type is aegyptaio 73 and this change is small and in an opposite
direction in the root extract type, bean.

The data can be analysed with the ordinary logistic regression model. This
replicates the result in Table 3 (1st column) in Breslow and Clayton (1993). I use
the _display_ function in the arm package, which shows summary result concisely
(AIC is calculated separately).

```
m1 <- glm(cbind(S, N-S) ~ X1 + X2, family = binomial, data = d)
arm::display(m1)
## Breslow's result in Table 3 p15
## glm(formula = cbind(S, N - S) ~ X1 + X2, family = binomial, data = d)
##             coef.est coef.se
## (Intercept) -0.43     0.11
## X1          -0.27     0.15
## X2           1.06     0.14
## ---
## n = 21, k = 3
## residual deviance = 39.7, null deviance = 98.7 (difference = 59.0)
## AIC: 122.28


m2 <- glm(cbind(S, N-S) ~ X1*X2, family = binomial, data = d)
arm::display(m2)
## glm(formula = cbind(S, N - S) ~ X1 * X2, family = binomial, data = d)
##             coef.est coef.se
## (Intercept) -0.56     0.13
## X1           0.15     0.22
## X2           1.32     0.18
## X1:X2       -0.78     0.31
## ---
## n = 21, k = 4
## residual deviance = 33.3, null deviance = 98.7 (difference = 65.4)
## AIC: 117.87

```

## Reference
* [Breslow, N. E., & Clayton, D. G. (1993). Approximate inference in generalized linear mixed models. _Journal of the American statistical Association_, 88(421), 9-25](http://www.jstor.org/stable/2290687).
* [Crowder, M. J. (1978). Beta-binomial anova for proportions. Applied statistics, 34-37](http://www.jstor.org/stable/2346223).

