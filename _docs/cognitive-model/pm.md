---
title: PM Model
category: Cognitive Model
order: 2
---

> Disclaimer: This tutorial is to fit Strickland et al's (2018) PM model. For any questions regarding the model, please contact luke.strickland@uwa.edu.au

When we mention memory, say a childhood event happening in the past, we are often talking about the _retrospective memory_, our memory for the past. _Prospective memory_, on the other hand, refers to we memorize something in order to do it in the future. For example, we set a reminder in the calender in our mobile phone to remind ourselves to do weekly shopping, say every Friday evening. When the reminder chimes, we then associate the reminder chime with the memory of "time to do the shopping. 

The prospective memory paradigm is a cognitive task testing such memory. It engages participants in some ongoing tasks with two basic choices. Take the lexical decision-making task (Wagenmakers, Ratcliff, Gomez, & McKoon, 2008) as an example, the choices are word vs. non-word. 

In this tutorial, we fit the prospective memory model to a simulated data set. In particular, we use a semi-factorial design from the Stricland et al (2018).  In addition to the two basic choices, word vs. non-word, the PM paradigms require participants to remember a third type of stimuli associated with a third response. This third type of stimuli is PM targets. For example, in addition to the typical word and non-word stimuli, participants occassionally were presented with a word describing an animal, like badger, otter, dolphin, wallaby, and so on, and the 
participants was instructed to choose the third response for the animal words.

# Experimental Design 
The semi-factorial design we illustrate here tested two factors. The first  factor is the stimulus factor, which has three levels, word, non-word and PM target. The second factor is the PM factor, which has three conditions. Condition 1 is the 'control' condition, in which participants responded to a typical 2AFC lexical decision-making task. 

Condition 2 is a 'focal' PM condition, with three stimulus types - word, non-word, and PM target, each associated with three separate response types. Comparing to the third condition described later, focal PM targets are easier to detect in the context of the ongoing task. For examine, the PM targets in a focal PM condition could be dog, cat, lion, tiger, panda, kangaroos and so on, those animals that are often mentioned.    

Condition 3 is a 'non-focal' PM condition, again with three types of stimuli - word, non-word, and PM target, each corresponding to three responses. Comparing to the focal condition, non-focal PM targets are more difficult to detect. Again, continuing with the animal example, non-focal PM target could be wombat, cheetah, echidna, devil, solenodon, and so on, those animals that are less frequently mentioned in everyday dialect.
  
In summary, factor 1, denoted as _S_, is a within-block manipulation of three-level stimulus type. Factor 2 is a between-block manipulation of three-level prospective memory. The three factor 2 levels are (1) no requirment to engage prospective memory, (2) easy prospective memory and (3) hard prospective memory. We denoted this factor as _cond_. In addition to the two factor, to determine whether a response is hit, correct rejection, false alarm or miss, we use a resposne factor, denoted as _R_, which has three levels, word, nonword and PM responses.

1. **S**, non-word (n), word (w), PM (p)
2. **cond**, focal (F), non-focal (H), control (C). 
3. **R**, nonword response (N), word response (W), PM response (P).

> Note we differentiate the upper- and the lower-case letters.

We assume an accumulator model where participants swap between two- and three-accumulator architectures. The model specification results in an incomplete crossing of the two factors, as there was no PM stimuli in the control blocks of trials. 

Table 1. Semi-factorial design.

|      | w   | n | p |
|------|-----|---|---|
|  C   | X   | X |   |
|  F   | X   | X | X |
|  H   | X   | X | X |


To set up a model object, we first create a list, named _FR_, pooling all three factors together.

```
FR <- list(S = c("n","w","p"), cond = c("C","F","H"), R = c("N","W","P"))
```

In prospective memory paradigms, we define the false alarms with regard to the PM responses as participants commit a PM response on a non-PM trial. We observe this type of false alarm are rare, and thereby the drift rate parameter associated with the PM-false-alarm accumulator are not constrained by much data. Thus, it is a good idea to pool those rates into one PM false alarm parameter (fa).


Table 2. Focal and non-focal conditions. The signal-detection categorization with regard to PM targets. O and X represents correct and incorrect responses. These two categories are correct rejections with regard to PM targets.

|R/S | w | n | p   |
|--- |---|---|---  |
|W   | O | X | miss|
|N   | X | O | miss|
|P   | fa| fa| hit |


To establish the relationship in Table 2 for the three PM conditions, we create a string vector, storing the factor levels. The _fa_ label represents false alarms. We use a trick to model the situation that the control condition has no PM targets and thereby participants would not even contemplate a PM response. Therefore, it makes sense to assume in the control blocks, participants engage a two-accumulator decision-making process, rather than 3-accumulator process, which possibly happens in the two PM conditions. We create a _FAKERATE_ label to signify this nuanced modelling approach. 

```
lev <- c("CnN","CwN", "CnW","CwW",
         "FnN","FwN","FpN", "FnW","FwW","FpW", "fa","FpP",
         "HnN","HwN","HpN", "HnW","HwW","HpW", "HpP", 
         "FAKERATE")
```


Table 3-1. Focal condition, using _lev_ labels.

|R/S | w  | n   | p   |
|--- |----|-----|-----|
|W   | FwW| FnW | FpW |
|N   | FwN| FnN | FpN |
|P   | fa | fa  | FpP |

Table 3-2. Non-focal condition, using _lev_ labels.

|R/S | w  | n   | p  |
|--- |----|-----|----|
|W   | HwW| HnW | HpW|
|N   | HwN| HnN | HpN|
|P   | fa | fa  | HpP|

Table 3-3. Control condition, using _lev_ labels.

|R/S | w   | n   | 
|--- |-----|-----|
|W   | CwW | CnW |
|N   | CwN | CnN |


Secondly, we use the _MakeEmptyMap_ function to create a NA vector. Each
of the elements in the vector is lablled by the 27 full-crossed factorial combinations.  


```
require(ggdmc)

map_mean_v <- ggdmc:::MakeEmptyMap(FR, lev)  
print(map_mean_v)
## n.C.N w.C.N p.C.N n.F.N w.F.N p.F.N n.H.N w.H.N p.H.N n.C.W w.C.W p.C.W 
## <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  

## n.F.W w.F.W p.F.W n.H.W w.H.W p.H.W n.C.P w.C.P p.C.P n.F.P w.F.P p.F.P 
## <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  

## n.H.P w.H.P p.H.P 
## <NA>  <NA>  <NA> 

length(map_mean_v)
## [1] 27

levels(map_mean_v)
##  [1] "CnN"      "CwN"      "CnW"      "CwW"      "FnN"      "FwN"      "FpN"     
##  [8] "FnW"      "FwW"      "FpW"      "fa"       "FpP"      "HnN"      "HwN"     
## [15] "HpN"      "HnW"      "HwW"      "HpW"      "HpP"      "FAKERATE"
```

Then we manually relabel the 27 elements, rendering the control condition to model two-accumulator process and the PM conditions to model three-accumulator process. That is, we label, for example p.C.N (i.e., a non-word response to a PM target in the control block), as _FAKERATE_.  Except the five _FAKERATE_ and four _fa_ conditions, the other conditions just remove the dot symbol and rearrange the labelling sequence of three factors as cond-S-R.

```
map_mean_v[1:27] <- c(
  "CnN","CwN","FAKERATE",
  "FnN","FwN","FpN",
  "HnN","HwN","HpN",
  
  "CnW","CwW","FAKERATE",
  "FnW","FwW","FpW",
  "HnW","HwW","HpW",
  
  "FAKERATE","FAKERATE","FAKERATE",
  "fa","fa","FpP",
  "fa","fa","HpP"
)

```

The following table compares the changes of labelling. 

|                 |       |       |        |       |       |       |       |
|---------------- |-------|-------|--------|-------|-------|-------|-------|
|map_mean_v before| n.C.N | w.C.N |p.C.N   | n.F.N | w.F.N | p.F.N | n.H.N | 
|map_mean_v after | CnN   | CwN   |FAKERATE| FnN   | FwN   | FpN   | HnN   |

|                 |       |       |          |       |         |       |       |
|---------------- |-------|-------|----------|-------|---------|-------|-------|
|map_mean_v before| w.H.N | p.H.N |  n.C.W   | w.C.W | p.C.W   | n.F.W | w.F.W | 
|map_mean_v after | HwN   | HpN   | CnW      | CwW   | FAKERATE| FnW   | FwW   |

|                 |       |       |       |       |        |        |        |
|---------------- |-------|-------|-------|-------|--------|--------|--------|
|map_mean_v before| p.F.W | n.H.W | w.H.W | p.H.W |  n.C.P | w.C.P  | p.C.P  | 
|map_mean_v after | FpW   | HnW   | HWW   | HpW   |FAKERATE|FAKERATE|FAKERATE|

|                 |     |       |       |      |      |      |
|---------------- |-----|-------|-------|------|------|------|
|map_mean_v before|n.F.P| w.F.P | p.F.P | n.H.P| w.H.P| p.H.P| 
|map_mean_v after |fa   | fa    | FpP   | fa   |  fa  |  HpP |



Instead of assigning the regular "M" factor to the mean_v parameter, which controls the LBA accumulator, we associate the mean_v parameter with the newly created **map_mean_v** vector. In the syntax of BuildModel, we assign the **map_mean_v** to a _MAPMV_ object by enter a list to the **match.map** option. 

## Model 0
The following model assumes the PM condition associates with the decision threshold and the drift rate is associated with the PM, stimulus and response conditions, following the above **map_mean_v** set up.

```
model0 <- BuildModel(
  p.map     = list(A = "1", B = c("cond", "R"), t0 = "1", mean_v = c("MAPMV"), 
                   sd_v = "1", st0 = "1", N = "cond"), 
  match.map = list(M = list(n = "N", w = "W", p = "P"), MAPMV = map_mean_v),
  factors   = list(S = c("n","w","p"), cond = c("C","F", "H")),
  constants = c(N.C = 2, N.F = 3, N.H = 3, st0 = 0, B.C.P = Inf, 
                mean_v.FAKERATE = 1, sd_v = 1), 
  responses = c("N", "W", "P"), 
  type      = "norm")

## Parameter vector names are: ( see attr(,"p.vector") )
##  [1] "A"          "B.C.N"      "B.F.N"      "B.H.N"      "B.C.W"      "B.F.W"     
##  [7] "B.H.W"      "B.F.P"      "B.H.P"      "t0"         "mean_v.CnN" "mean_v.CwN"
## [13] "mean_v.CnW" "mean_v.CwW" "mean_v.FnN" "mean_v.FwN" "mean_v.FpN" "mean_v.FnW"
## [19] "mean_v.FwW" "mean_v.FpW" "mean_v.fa"  "mean_v.FpP" "mean_v.HnN" "mean_v.HwN"
## [25] "mean_v.HpN" "mean_v.HnW" "mean_v.HwW" "mean_v.HpW" "mean_v.HpP"
## 
## Constants are (see attr(,"constants") ):
##             N.C             N.F             N.H             st0           B.C.P 
##               2               3               3               0             Inf 
## mean_v.FAKERATE            sd_v 
##               1               1 
## 
## Model type = norm (posdrift = TRUE )
```

A note to the value entered for the constants argument. The N.C, N.F and N.H in the constants argument represents the number of accumulators in the control, focal and non-focal conditions are 2, 3 and 3, respectively. The **B.C.P** represents the LBA _B_ parameter (b = A + B) of the PM accumulator in the control condition is fixed at infinitve. This is another trick, signifying this particular accumulator requires infinitive amount of evidence to trigger a decision. The drift rate of the FAKERATE accumulator is set at one, which is inconsequential because its threshold is infinitive.  

> A reminder: The LBA _B_ parameter represents the travelling distance of an accumulator. The threshold parameter is denoted as $$b = A + B$$. _A_ is the LBA starting point parameter. 


This is a rather nuanced model object. Let's check its internal to see how the 2 and 3 alternating accumulators are set up for the different PM condition. 

```
npar <- length(GetPNames(model0))

## Create a true parameter vector for recovery
p.vector <- c(A = .3, B.C.N = 1.3,  B.F.N = 1.3,  B.H.N = 1.3,
              B.C.W = 1.3,  B.F.W = 1.4,  B.H.W = 1.5,
              B.F.P = 1.1,  B.H.P = 1.3,

              t0=.1,

              mean_v.CnN = 2.8,  mean_v.CwN = -0.3, mean_v.CnW=-1,
              mean_v.CwW = 2.9,  mean_v.FnN = 2.8,  mean_v.FwN=-.3,

              mean_v.FpN = -1.6, mean_v.FnW = -1,   mean_v.FwW = 2.9,
              mean_v.FpW = .5 ,  mean_v.fa = -2.4,  mean_v.FpP = 2.5,

              mean_v.HnN = 2.8, mean_v.HwN = -.5,   mean_v.HpN = -.6,
              mean_v.HnW = -.7, mean_v.HwW = 3.0,   mean_v.HpW = 1.6,
              mean_v.HpP = 2.3)

dat0 <- simulate(model0, nsim=1e2, ps=p.vector)
dmi0 <- BuildDMI(dat0, model0)

## Remember in "Model Array" tutorial, we introduce the model object is a 3-D 
## TRUE-FALSE array. Its first dimention is the factorial combination (aka 
## design cell).
dim0 <- cell <- dimnames(model0)[[1]]
print(dim0)
##  [1] "n.C.N" "w.C.N" "p.C.N" "n.F.N" "w.F.N" "p.F.N" "n.H.N" "w.H.N" "p.H.N" "n.C.W"
## [11] "w.C.W" "p.C.W" "n.F.W" "w.F.W" "p.F.W" "n.H.W" "w.H.W" "p.H.W" "n.C.P" "w.C.P"
## [21] "p.C.P" "n.F.P" "w.F.P" "p.F.P" "n.H.P" "w.H.P" "p.H.P"
```

TableParameters constructs an accumulator-parameter table with each row representing an accumulator and each column representing a parameter.

```
acc_tab0 <- TableParameters(p.vector, 1, model0, FALSE)
acc_tab1 <- TableParameters(p.vector, "w.C.N", model0, FALSE)
acc_tab2 <- TableParameters(p.vector, "w.F.P", model0, FALSE)

print(acc_tab0)
print(acc_tab1)
print(acc_tab2)

##     A   b  t0 mean_v sd_v st0 nacc
## 1 0.3 1.6 0.1    2.8    1   0    2
## 2 0.3 1.6 0.1   -1.0    1   0    2
## 3 0.3 Inf 0.1    1.0    1   0    2
##     A   b  t0 mean_v sd_v st0 nacc
## 1 0.3 1.6 0.1   -0.3    1   0    2
## 2 0.3 1.6 0.1    2.9    1   0    2
## 3 0.3 Inf 0.1    1.0    1   0    2
##     A   b  t0 mean_v sd_v st0 nacc
## 1 0.3 1.6 0.1   -0.3    1   0    3
## 2 0.3 1.7 0.1    2.9    1   0    3
## 3 0.3 1.4 0.1   -2.4    1   0    3
```

Note that _TableParameters_ has calculated b (=A+B). The 7th column indicates the number of accumulator in this condition. It describes the condition, so the 2nd and 3rd rows in the 7th column is redundant.
 
After setting up the model, the sampling procedure is very much a routine. We set up prior distributions for the 29 parameters. In this case of a simulation study, we can check whether the prior distributions are improbable with respect to the true parameter.

```
pname <- GetPNames(model0)
p.prior0 <- BuildPrior(
  dists = c(rep("tnorm", 9), "beta", rep("tnorm", 19)),
  p1    = rep(1, npar),
  p2    = c(rep(2, 9), 1, rep(2, 19)),
  lower = c(rep(0, 10),  rep(NA, 19)),
  upper = c(rep(NA, 9), 1, rep(NA, 19)))
names(p.prior0) <- pname

plot(p.prior0, ps = p.vector)

## Sampling. We turned off the block-sampling to update an entire parameter at once.
## The block-sampling method updates only some of the parameters in a parameter vector.  
fit0 <- StartNewsamples(dmi, p.prior0, block = FALSE, thin=2)
fit0_correct  <- run(fit0, thin=2, block = FALSE)
hat  <- gelman(fit0_correct, verbose=TRUE);
est  <- summary(fit0_correct, recovery = TRUE, ps = p.vector, verbose = TRUE)
```

## Model 1
To test the role of the PM condition on its influence on the decision threshold, we fit a second model assuming no association between the threshold and the PM condition. 

```
## map_mean_v is identical as before
model1 <- ggdmc:::BuildModel(
  p.map     = list(A = "1", B = "R", t0 = "1", mean_v = "MAPMV",
                   sd_v = "1", st0 = "1", N = "cond"),
  match.map = list(M = list(n = "N", w = "W", p = "P"),
                   MAPMV = map_mean_v),
  factors   = list(S = c("n","w","p"), cond = c("C","F", "H")),
  constants = c(N.C = 2, N.F = 3, N.H = 3, st0 = 0,
                mean_v.FAKERATE = 1, sd_v = 1),
  responses = c("N", "W", "P"),
  type      = "norm")

ggdmc:::GetPNames(model1)

## Set up a different p.vector to test whether we can also recover this set.
p.vector <- c(A = .5, B.N = 1.2,  B.W = 1,  B.P = 1.5,
              t0=.15,

              mean_v.CnN = 1.25, mean_v.CwN = .35, mean_v.CnW = .25,
              mean_v.CwW = 1.15, mean_v.FnN = 1.8, mean_v.FwN = .35,

              mean_v.FpN = .12, mean_v.FnW = .11, mean_v.FwW = 1.32,
              mean_v.FpW = 1.33, mean_v.fa = -1.2, mean_v.FpP = 1.45,

              mean_v.HnN = 1.67, mean_v.HwN = .14, mean_v.HpN = .23,
              mean_v.HnW = .3, mean_v.HwW = 1.21, mean_v.HpW = 1.5,
              mean_v.HpP = 1.11)


dat1 <- simulate(model1, nsim=1e2, ps=p.vector)
dmi1 <- BuildDMI(dat1, model)

pname <- ggdmc:::GetPNames(model1)
npar <- length(pname)
p.prior1 <- ggdmc:::BuildPrior(
  dists = c(rep("tnorm", 4), "beta", rep("tnorm", 19)),
  p1    = rep(1, npar),
  p2    = c(rep(2, 4), 1, rep(2, 19)),
  lower = c(rep(0, 5),  rep(NA, 19)),
  upper = c(rep(NA, 4), 1, rep(NA, 19)))
names(p.prior1) <- pname
plot(p.prior1, ps = p.vector)

fit0 <- StartNewsamples(dmi1, p.prior1, block = FALSE, thin=2)
fit1_correct  <- run(fit0, thin=4, block = FALSE)
hat  <- gelman(fit1_correct, verbose=TRUE);
est  <- summary(fit1_correct, recovery = TRUE, ps = p.vector, verbose = TRUE)
#                    A   B.N   B.P  B.W mean_v.CnN mean_v.CnW mean_v.CwN mean_v.CwW
# True            0.50  1.20  1.50 1.00       1.25       0.25       0.35       1.15
# 2.5% Estimate   0.02  0.66  0.65 0.66       0.99      -0.56      -0.56       0.65
# 50% Estimate    0.39  1.16  1.17 1.13       1.33      -0.02      -0.02       1.00
# 97.5% Estimate  1.09  1.50  1.65 1.46       1.64       0.45       0.44       1.32
# Median-True    -0.11 -0.04 -0.33 0.13       0.08      -0.27      -0.37      -0.15
#                mean_v.fa mean_v.FnN mean_v.FnW mean_v.FpN mean_v.FpP mean_v.FpW
# True               -1.20       1.80       0.11       0.12       1.45       1.33
# 2.5% Estimate      -2.66       1.42      -1.01       0.02       0.88       0.74
# 50% Estimate       -1.56       1.74      -0.33       0.54       1.49       1.12
# 97.5% Estimate     -0.75       2.04       0.26       0.99       2.01       1.48
# Median-True        -0.36      -0.06      -0.44       0.42       0.04      -0.21
#                mean_v.FwN mean_v.FwW mean_v.HnN mean_v.HnW mean_v.HpN mean_v.HpP
# True                 0.35       1.32       1.67       0.30       0.23       1.11
# 2.5% Estimate       -0.45       0.84       1.09      -0.24      -0.37       0.47
# 50% Estimate         0.11       1.18       1.41       0.27       0.20       1.10
# 97.5% Estimate       0.57       1.49       1.72       0.70       0.68       1.66
# Median-True         -0.24      -0.14      -0.26      -0.03      -0.03      -0.01
#                mean_v.HpW mean_v.HwN mean_v.HwW   t0
# True                 1.50       0.14       1.21 0.15
# 2.5% Estimate        0.84      -0.63       0.58 0.10
# 50% Estimate         1.20      -0.11       0.94 0.16
# 97.5% Estimate       1.54       0.36       1.28 0.26
# Median-True         -0.30      -0.25      -0.27 0.01

```

# Model Comparison

```
## Use model 0 to fit data generated by model 1
fit0 <- StartNewsamples(dmi0_wrong, p.prior0, block = FALSE, thin=2)
fit0_wrong  <- run(fit0, thin=4, block = FALSE)
hat  <- gelman(fit0_wrong, verbose=TRUE);

## Use model 1 to fit data generated by model 0
fit0 <- StartNewsamples(dmi1_wrong, p.prior1, block = FALSE, thin=2)
fit1_wrong  <- run(fit0, thin=4, block = FALSE)
hat  <- gelman(fit1_wrong, verbose=TRUE);

## This compares using model0 and model 1 to fit dat0.
## The cond factor does not affect the B parameter, because the DIC difference 
## is small.
DIC(fit0_correct); DIC(fit1_wrong)
# [1] 319.4222
# [1] 314.2239

## This compares using model0 and model 1 to fit dat1.
## The cond factor does not affect the B parameter,  because the DIC difference 
## is small.
DIC(fit1_correct); DIC(fit0_wrong); 
# [1] 2078.136
# [1] 2080.449
```

# Modelling Data from Multiple Participants

```
## Model 1 --------------------------------------------
## 27 elements with 20 levels
## Population distribution, 
pop.mean <- c(A = .3, B.C.N = 1.3,  B.F.N = 1.3,  B.H.N = 1.3,
               B.C.W = 1.3,  B.F.W = 1.4,  B.H.W = 1.5,
               B.F.P = 1.1,  B.H.P = 1.3,

               t0=.1,

               mean_v.CnN = 2.8,  mean_v.CwN = -0.3, mean_v.CnW=-1,
               mean_v.CwW = 2.9,  mean_v.FnN = 2.8,  mean_v.FwN=-.3,

               mean_v.FpN = -1.6, mean_v.FnW = -1,   mean_v.FwW = 2.9,
               mean_v.FpW = .5 ,  mean_v.fa = -2.4,  mean_v.FpP = 2.5,

               mean_v.HnN = 2.8, mean_v.HwN = -.5,   mean_v.HpN = -.6,
               mean_v.HnW = -.7, mean_v.HwW = 3.0,   mean_v.HpW = 1.6,
               mean_v.HpP = 2.3)

pop.scale <-c(A = .05, B.C.N = .05,  B.F.N = .05,  B.H.N = .05,
              B.C.W = .05,  B.F.W = .05,  B.H.W = .05,
              B.F.P = .05,  B.H.P = .05,
              t0=.05,

               mean_v.CnN = .05,  mean_v.CwN = .05, mean_v.CnW = .05,
               mean_v.CwW = .05,  mean_v.FnN = .05,  mean_v.FwN = .05,

               mean_v.FpN = .05, mean_v.FnW = .05,   mean_v.FwW = .05,
               mean_v.FpW = .05,  mean_v.fa = .05,  mean_v.FpP = .05,

               mean_v.HnN = .05, mean_v.HwN = .05,   mean_v.HpN = .05,
               mean_v.HnW = .05, mean_v.HwW = .05,   mean_v.HpW = .05,
               mean_v.HpP = .05)

pop.prior <- BuildPrior(
   dists = rep("tnorm", 29),
   p1 = pop.mean,
   p2 = pop.scale,
   lower = c(rep(0, 9), .1, rep(NA, 19)),
   upper = c(rep(NA,9),  1, rep(NA, 19)))

dat0 <- simulate(model0, nsub = 12, nsim = 50, prior = pop.prior)
dmi0 <- BuildDMI(dat0, model0)
ps0 <- attr(dat0, "parameters")

pname <- GetPNames(model0)
p.prior <- BuildPrior(
   dists = c(rep("tnorm", 9), "beta", rep("tnorm", 19)),
   p1    = rep(1, npar),
   p2    = c(rep(2, 9), 1, rep(2, 19)),
   lower = c(rep(0, 10),  rep(NA, 19)),
   upper = c(rep(NA, 9), 1, rep(NA, 19)))
mu.prior <- BuildPrior(
   dists = c(rep("tnorm", 9), "beta", rep("tnorm", 19)),
   p1    = rep(1, npar),
   p2    = c(rep(2, 9), 1, rep(2, 19)),
   lower = c(rep(0, 10),  rep(NA, 19)),
   upper = c(rep(NA, 9), 1, rep(NA, 19)))
sigma.prior <- BuildPrior(
   dists = rep("beta", npar),
   p1    = rep(1, npar),
   p2    = rep(1, npar))
names(p.prior) <- pname
names(mu.prior) <- pname
names(sigma.prior) <- pname
priors0 <- list(pprior=p.prior, location=mu.prior, scale=sigma.prior)
save(model0, dat0, dmi0, ps0, priors0, file = "tests/Group2/PM12S.RData")

## Sampling separately ----------
load("tests/Group2/PM12S.RData")
fit0 <- StartNewsamples(dmi0, priors0[[1]], ncore=6, thin=4)
fit  <- run(fit0, thin=2, ncore=6)
est0 <- summary(fit, recovery = TRUE, ps = ps0, verbose =TRUE)
rhat0 <- gelman(fit, verbose=TRUE)
save(fit0, fit, model0, dat0, dmi0, ps0, priors0, file = "tests/Group2/PM12S.RData")
```


# Reference
* Strickland, L., Loft, S., Remington, R. W., & Heathcote, A. (2018). Racing to remember: A theory of decision control in event-based prospective memory. Psychological Review, 125(6), 851-887. http://dx.doi.org/10.1037/rev0000113
* Wagenmakers, E.-J., Ratcliff, R., Gomez, P., & McKoon, G. (2008). A diffusion model account of criterion shifts in the lexical decision task. _Journal of Memory and Language_, 58, 140-159. doi:10.1016/j.jml.2007.04.006.


