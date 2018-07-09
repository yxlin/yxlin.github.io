---
title: Model Array
category: Modelling Basics
order: 1
---

The fundamental concept in any sort of factorial designs is
a model matrix underlying the assignment of experimental conditions to their
corresponding cognitive parameters, which often are those cognitive 
operations that cannot be directly observed, such as memory decay, rates of
evidence accumulation, response thresholds. Although in linear regression 
models one might be interested in examining intercept and slope,
psychologist often are really interested in the parameters underlying
cognitive operations. Therefore, the first step in **_ggdmc_** (as well
as DMC) is to set up a 3-D model array, which serves for this purpose.

_BuildModel_ creates a model array, which composes of many model matrices.
Each of them represents a response.  The content of a model matrix indicates the
correspondence of parameters and design cells. For example, if a data set has
a two-level stimulus factor, affecting the drift rate (as in DDM), a
model matrix will have two drift rate parameters, say, v.d1 and v.d2
(_d_ stands for difficulty). One could understand this idea of correspondence
between an experimental factor and its parameter mapping by examining the
following example.

# Example 1
In this example, I used Brown and Heathcote's LBA model (2008) to illustrate, fitting
data from a single participant. The LBA's _B_ parameter depends response (R)
and correctness (M, for match) in a design with one two-level stimulus
factor (S).  The accuracy is determined by S and R.  The M factor is a specific
latent factor just for the LBA.

```
 model <- BuildModel(
   p.map     = list(A = "1", B = "R", t0 = "1", mean_v = "M", sd_v = "M", st0 = "1"),
   match.map = list(M = list(s1 = "r1", s2 = "r2")),
   factors   = list(S = c("s1", "s2")),
   constants = c(sd_v.false = 1, st0 = 0),
   responses = c("r1", "r2"),
   type      = "norm")
```

_p.map_ means parameter map. _match.map_ matches the stimulus type to the response
type to determine if an observed response is correct or error. _factors_ means
experimental factors, _constants_ specifies which model parameter to fix as 
constant values. This is to enforce model assumptions. _responses_ indicates response
types, by specifying character strings or numbers. Lastly, _type_ specifies
the model types, such as the diffusion decision model (_rd_) or the LBA (_norm_).

For illustration purpose, I simulated some realistic response time data. I
made up a true parameter vector. This is usually unknown and estimated from data.

``` 
p.vector  <- c(A = .75, B.r1 = .25, B.r2 = .15, t0 = .2, mean_v.true = 2.5,
               mean_v.false = 1.5, sd_v.true = 0.5)
```

_print_ will show your the model array together with its attributes that have
been added into in the _BuildModel_ step.

```
print(model)

## r1 
##          A B.r1  B.r2   t0 mean_v.true mean_v.false sd_v.true sd_v.false  st0
## s1.r1 TRUE TRUE FALSE TRUE        TRUE        FALSE      TRUE      FALSE TRUE
## s2.r1 TRUE TRUE FALSE TRUE       FALSE         TRUE     FALSE       TRUE TRUE
## s1.r2 TRUE TRUE FALSE TRUE        TRUE        FALSE      TRUE      FALSE TRUE
## s2.r2 TRUE TRUE FALSE TRUE       FALSE         TRUE     FALSE       TRUE TRUE
## r2 
##          A  B.r1 B.r2   t0 mean_v.true mean_v.false sd_v.true sd_v.false  st0
## s1.r1 TRUE FALSE TRUE TRUE       FALSE         TRUE     FALSE       TRUE TRUE
## s2.r1 TRUE FALSE TRUE TRUE        TRUE        FALSE      TRUE      FALSE TRUE
## s1.r2 TRUE FALSE TRUE TRUE       FALSE         TRUE     FALSE       TRUE TRUE
## s2.r2 TRUE FALSE TRUE TRUE        TRUE        FALSE      TRUE      FALSE TRUE
## model has the following attributes: 
##  [1] "dim"        "dimnames"   "all.par"    "p.vector"   "pca"        "par.names" 
##  [7] "type"       "factors"    "responses"  "constants"  "posdrift"   "n1.order"  
## [13] "match.cell" "match.map"  "class"     

```


_print_, when supplied with a true parameter vector, will show how the factorial
design is assigned to model parameters.  Understanding the assigning process is
an advanced topic.  I will return to it at a later section.  Note that here I,
using Brown and Heathcote's (2008) convention, differentiate the lowercase
_b_ and uppercase _B_ in the LBA model. The former means the threshold parameter,
and the latter is the travel distance parameter. The LBA model assumes
_b = A + B_.



```
print(model, p.vector)
## "s1.r1"
##    A   b  t0 mean_v sd_v st0
## 0.75 1.0 0.2    2.5  0.5   0
## 0.75 0.9 0.2    1.5  1.0   0
## "s2.r1"
##    A   b  t0 mean_v sd_v st0
## 0.75 1.0 0.2    1.5  1.0   0
## 0.75 0.9 0.2    2.5  0.5   0
## "s1.r2"
##    A   b  t0 mean_v sd_v st0
## 0.75 0.9 0.2    1.5  1.0   0
## 0.75 1.0 0.2    2.5  0.5   0
## "s2.r2"
##    A   b  t0 mean_v sd_v st0
## 0.75 0.9 0.2    2.5  0.5   0
## 0.75 1.0 0.2    1.5  1.0   0
```

