---
title: Simulation
category: Modelling Basics
order: 2
---


In this tutorial, I demonstrated the method of simulating the data for a
participant. _simulate_ creates a (R) data frame based on the parameter
vector and the model with _nsim_ observations for each row in model. _ps_
is the true parameter vector.

```
model <- BuildModel(
   p.map     = list(A = "1", B = "R", t0 = "1", mean_v = "M", sd_v = "M", st0 = "1"),
   match.map = list(M = list(s1 = "r1", s2 = "r2")),
   factors   = list(S = c("s1", "s2")),
   constants = c(sd_v.false = 1, st0 = 0),
   responses = c("r1", "r2"),
   type      = "norm")
   
p.vector  <- c(A = .75, B.r1 = .25, B.r2 = .15, t0 = .2, mean_v.true = 2.5,
               mean_v.false = 1.5, sd_v.true = 0.5)

set.seed(123)  ## Set seed to get the same simulation
dat <- simulate(model, nsim = 1, ps = p.vector)

##    S  R        RT
## 1 s1 r1 0.3327392
## 2 s2 r1 0.3797985

```


Simulate 100 responses for each condition. In this model, I
generated 200 responses in total.

```
ntrial <- 1e2
dat <- simulate(model, nsim = ntrial, ps = p.vector)
data.table::data.table(dat)
##       S  R        RT
##   1: s1 r2 0.5228495
##   2: s1 r1 0.4627093
##   3: s1 r1 0.4418045
##   4: s1 r1 0.5376318
##   5: s1 r1 0.3119197
##  ---                
## 196: s2 r2 0.3706081
## 197: s2 r1 0.4762363
## 198: s2 r1 0.4797071
## 199: s2 r2 0.5076515
## 200: s2 r2 0.3883532
```


Model and data are two separate objects. To fit data with a certain model,
I bind them together with _BindDataModel_.  This is to facilitate model
comparison. That is, a data set can bind with many different models, so
we can compare them to see which model may fit the data better or provide
a better account. I used a term, data-model instance (dmi),
coined by Matthew Gretton. 

```
dmi <- BindDataModel(dat, model)
```


We can use DMC's base plot function to check the accuracy and RT distributions
for each stimulus level. Correct responses are in black and error responses are
in red.

```
par(mfrow = c(1, 2), mar = c(4, 5.3, 0.82, 1))
plot.cell.density(dmi[dmi$S=="s1",], C="r1", xlim=c(0,4))
plot.cell.density(dmi[dmi$S=="s2",], C="r2", xlim=c(0,4))
par(mfrow=c(1, 1))

```

![distributions]({{"/images/density.png" | absolute_url}})
