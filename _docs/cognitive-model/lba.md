---
title: The Linear Ballistics Accumulation Model
category: Cognitive Model
order: 1
---


Here I used an experimental design with a binary stimulus factor (S),
which for example left vs. right motion random dots. The LBA model,
presumes one matching (M) factor and an observable accumulator factor (R),
corresponding responses. 


```
model <- BuildModel(p.map = list(A = "1", B = "1", t0 = "1", mean_v = "M",
                         sd_v = "M", st0 = "1"),
  constants = c(st0 = 0, sd_v.false = 1, mean_v.false = 0),
  match.map = list(M = list(left = "LEFT", right = "RIGHT")),
  factors   = list(S = c("left", "right")),
  responses = c("LEFT", "RIGHT"),
  type      = "norm")
```


This specific design assumes no manipulation, affecting any the LBA
parameters. That is, no factor affects any latent cognitive
processes (e.g., drift rate, response threshold etc.). The only effect
is that the
drift rate for a correct response is usually
larger than that for an error response (from psychological literature ).
This is artificial set at

> constants = c(st0 = 0, sd_v.false = 1, mean_v.false = 0),

, which enforces **mean_v.false = 0**. This is to enforce the
assumption (also frequent observed phenomenon) that manifested
accuracy rate should usually be greater than chance (50%).

1. Fast and error prone performance
Note sd_v.true (0.66) < sd_v.false (1) as is often seen in empirical data.


```
pvec1 <- c(A = 1, B = 0, t0 = .2, mean_v.true = 1, sd_v.true = 0.66)
dat1  <- simulate(model, ps = pvec1, nsim = 16384), model)
dmi1  <- BindDataModel(dat1, model)

```



```
## Score & plot
## a. Error and correct responses have similar mean RTs.
## b. Stimulus type 1 and stimulus type 2 have similar accuracy
correct <- dmi1$S == tolower(dmi1$R)
round(tapply(dmi1$RT, list(correct), mean), 2)
round(tapply(correct, list(dmi1$S),  mean), 2)
ggdmc::plot_dist(dmi1, xlim = c(0, 5))
```
