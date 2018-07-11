---
title: Shooting Decision Model II
category: Hierarchical Model
order: 5
---

I continue the shooting decision model by fitting the empirical data in study 3 in Pleskac,
Cesario and Johnson (2017).


First I loaded the empirical data and the model and prior distributions I had set up
in previous tutorial.

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

> edat <- data.frame(study3_subset)
> edmi <- BindDataModel(edat, model)

Next is just to repeat what I had done in the recovery study.

```
ehsam <- run(StartNewHypersamples(5e2, edmi, p.prior, pp.prior, 32),
  pm = .3, hpm = .3) ## 18 mins
ehsam <- run(RestartHypersamples(5e2, hsam, thin = 32),
  pm = .3, hpm = .3) ## 3 hrs

save(model, p.prior, pp.prior, pop.prior, nsubject, ntrial, dat, dmi, hsam,
  npar, pop.mean, pop.scale, ps, study3, edat, edmi, ehsam,
  file = "data/race/shoot-decision-recovery-study3.rda")
```


As usual, I set up an automatic fitting routine to fit the model until it
converge.

```
## 8 hr
counter <- 1
repeat {
  ehsam <- run(RestartHypersamples(5e2, hsam, thin = 32),
    pm = .3, hpm = .3)
  save(model, p.prior, pp.prior, pop.prior, nsubject, ntrial, dat, dmi, hsam,
    npar, pop.mean, pop.scale, ps, study3, edat, edmi, ehsam, counter,
    file = "data/race/shoot-decision-recovery-study3.rda")
  rhats <- hgelman(ehsam)
  counter <- counter + 1
  thin <- thin * 2
  if (all(rhats < 1.1) || counter > 1e2) break
}
```


## Reference
Pleskac, T.J., Cesario, J. & Johnson, D.J. (2017). How race affects evidence accumulation during the decision to shoot.
_Psychonomic Bulletin & Review_, 1-30. https://doi.org/10.3758/s13423-017-1369-6

Wong, J. C. (2016, Aprial, 18). ['Scapegoated?' The police killing that left Asian Americans angry – and divided](https://www.theguardian.com/world/2016/apr/18/peter-liang-akai-gurley-killing-asian-american-response).
_The Guardian_.

[Chinese Community Reels After Brooklyn NYPD Shooting](https://www.nbcnews.com/news/asian-america/chinese-community-reels-after-brooklyn-nypd-shooting-n273931). (2014, December 24). _NBC News_.

[American's police on trial](https://www.economist.com/leaders/2014/12/11/americas-police-on-trial). (2014, December, 11). _The Economist_.

