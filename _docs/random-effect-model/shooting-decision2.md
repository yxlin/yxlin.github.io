---
title: Shooting Decision Model I - Empirical Data
category: Hierarchical Model
order: 5
---

I continued the shooting decision model by fitting the empirical data in study 3 in Pleskac,
Cesario and Johnson (2017). First I loaded the empirical data. Then I loaded the model
object and prior distributions that had set up in the previous tutorial.

```
require(ggdmc)
load("data/race/study3.rda")
load("data/race/shoot-decision-recovery.rda")

study3_subset <- study3[, c("s", "S", "RACE", "R", "RT")]
dplyr::tbl_df(study3_subset)

## A tibble: 12,033 x 5
##     s     S     RACE   R     RT
##    <fct> <fct> <fct> <fct> <dbl>
##  1 11    gun   black not   0.753
##  2 11    non   white shoot 0.851
##  3 11    gun   black not   0.742
##  4 11    non   white shoot 0.636
##  5 11    gun   black shoot 0.644
##  6 11    non   black not   0.625
##  7 11    non   white shoot 0.889
##  8 11    gun   black not   0.597
##  9 11    gun   white not   0.724
## 10 11    non   white shoot 0.656
## ... with 12,023 more rows
```

To match the abbreviations used in the model object, I changed the "non", and
"gun" to "N" and "G" as well as "black" and "white" to "A" and "E".

> study3_subset$S    <- factor(ifelse(study3_subset$S == "non", "N", "G"))
> study3_subset$RACE <- factor(ifelse(study3_subset$RACE == "black", "A", "E"))


Then I converted the _data.table_ to _data.frame_, which was then bound to the
model object.

> edat <- data.frame(study3_subset);

> edmi <- BindDataModel(edat, model)

Next is just to repeat what I had done in the recovery study.

```
path <- "data/race/Study3/DDM/stimulus-threshold.rda"
ehsam <- run(StartNewHypersamples(5e2, edmi, p.prior, pp.prior, 32),
  pm = .3, hpm = .3) ## 18 mins
ehsam <- run(RestartHypersamples(5e2, hsam, thin = 32),
  pm = .3, hpm = .3) 
save(model, p.prior, pp.prior, pop.prior, nsubject, ntrial, dat, dmi, hsam,
       npar, pop.mean, pop.scale, ps, study3, edat, edmi, ehsam, counter,
       file = path)
```


I then set up an automatic fitting routine to fit the model until it
converges.

```
counter <- 1
repeat {
  ehsam <- run(RestartHypersamples(5e2, hsam, thin = 32),
    pm = .3, hpm = .3)
  save(model, p.prior, pp.prior, pop.prior, nsubject, ntrial, dat, dmi, hsam,
    npar, pop.mean, pop.scale, ps, study3, edat, edmi, ehsam, counter,
    file = path)
  rhats <- hgelman(ehsam)
  counter <- counter + 1
  thin <- thin * 2
  if (all(rhats < 1.1) || counter > 1e2) break
}
```

## Model Diagnosis

- Potential scale reduction factor (psrf)
- Effective sample sizes


```
rhats <- hgelman(ehsam)
# Diagnosing theta for many participants separately
# Diagnosing the hyper parameters, phi
# hyper    1     2     3     4     5     6     7     8     9    10    11    12    13
# 1.03  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00
#   14    15    16    17    18    19    20    21    22    23    24    25    26    27
# 1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00  1.00
#   28    29    30    31    32    33    34    35    36    37    38
# 1.00  1.00  1.00  1.00  1.00  1.00  1.01  1.01  1.01  1.01  1.01

effectiveSize(ehsam, hyper = TRUE)
# a.E.h1 a.A.h1 v.G.h1 v.N.h1   z.h1  sz.h1  sv.h1  t0.h1 a.E.h2 a.A.h2 v.G.h2 v.N.h2
# 2047   1985   1337   1819   1995    981   1444   2084   1724   1874   1314   1666
# z.h2  sz.h2  sv.h2  t0.h2
# 1936   1072   1267   1957
effectiveSize(ehsam, verbose = TRUE)
#       a.E  a.A  v.G  v.N    z   sz   sv   t0
# MEAN 6295 5888 5464 6021 7029 5339 5895 6457
# SD    940  937  964  922  987  767  948  612
# MAX  7366 7202 6483 7403 7979 6783 7350 7372
# MIN  2042 1873 1922 2037 1922 1930 2147 3914
```



- Trace plots for the log-posterior likelihood at the hyper level
- Trace plots for hyper parameters
- Posterior density plots for the hyper parameters
- Trace plots for the log-posterior likelihood at the data level
- Posterior density plots for the DDM parameters in the 38 participants

The last figures were not presented here. They were printed separately
in a pdf file for later checking.
```
p1 <- plot(ehsam, hyper = TRUE)
p2 <- plot(ehsam, hyper = TRUE, pll = FALSE)
p3 <- plot(ehsam, hyper = TRUE, pll = FALSE, den = TRUE)
p4 <- plot(ehsam)
p5 <- plot(ehsam, pll = FALSE, den = TRUE) 
```

![hyper]({{"/images/random-effect-model/shooting/hyper.png" | relative_url}})

## Reference
Pleskac, T.J., Cesario, J. & Johnson, D.J. (2017). How race affects evidence accumulation during the decision to shoot.
_Psychonomic Bulletin & Review_, 1-30. https://doi.org/10.3758/s13423-017-1369-6

