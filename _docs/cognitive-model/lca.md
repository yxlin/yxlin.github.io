---
title: LCA Model
category: Cognitive Model
order: 8
---

> The LCA and simulated PDF modules have not uploaded to GitHub. 

This tutorial demonstrates the method of conducting maximum likelihood 
parameter estimation for the leaking, competing accumulator model. You will 
need the subplex routines for optimization, because I use the PDA to construct
the simulated PDF of the LCA model. The simulated PDF is an approximation of 
analytic PDF, so sPDF is noisy. The subplex is designed to handle such 
situation. The package can be downloaded from 
https://github.com/kingaa/subplex/ or CRAN.
 
```
rm(list = ls())
setwd('~/Documents/LCA5/tests/Group3/')
load("LCA1S_MLE_1e2_subplex.RData")
load("LCA1S_MLE_1e3_subplex.RData")
require(ggdmc); require(subplex)

model <- BuildModel(
  p.map     = list(kappa = "1", beta = "1", Z="1", s = "1", t0 = "1",
                   I = "M", x0 = "1"),
  match.map = list(M = list(s1 = 1, s2 = 2, s3=3)),
  factors   = list(S = c("s1", "s2", "s3")),
  constants = c(s = .1),
  responses = c("r1", "r2", "r3"),
  type      = "lca")

p.vector  <- c(kappa=1.15, beta=1, Z=0.5, t0=.200, I.true=1.2, I.false=1, x0 =.15)
nsim <- ntrial <- 1e2
## nsim <- ntrial <- 1e3

## use the seed option to make sure I always replicate the result
## remove it, if you want to see the stochastic process.
dat <- simulate(model, nsim = ntrial, ps = p.vector, seed = 123)
dmi <- BuildDMI(dat, model)
d <- data.table::data.table(dat)
## This is to create a column in the data frame to indicate
## correct and error responses.
## sapply(d[, .(S,R)], levels)


dmi$C <- ifelse(dmi$S == "s1" & dmi$R == "r1", TRUE,
         ifelse(dmi$S == "s2" & dmi$R == "r2", TRUE,
         ifelse(dmi$S == "s3" & dmi$R == "r3", TRUE,
         ifelse(dmi$S == "s1" & dmi$R == "s3", FALSE,
         ifelse(dmi$S == "s1" & dmi$R == "r2" ,FALSE,
         ifelse(dmi$S == "s2" & dmi$R == "r1", FALSE,
         ifelse(dmi$S == "s2" & dmi$R == "r3", FALSE,
         ifelse(dmi$S == "s3" & dmi$R == "r1", FALSE,
         ifelse(dmi$S == "s3" & dmi$R == "r2", FALSE, NA)))))))))

prop.table(table(dmi$C))

## The maximum (log) likelihoods
## den <- likelihood(p.vector, dmi)
## sum(log(den))

objective_fun <- function(par, data) {
  den <- likelihood(par, data)
  return(-sum(log(den)))
}

init_par <- runif(length(p.vector))
init_par[4] <- runif(1, 0, min(dmi$RT)) 
names(init_par) <- names(p.vector)

## 8.1 hrs for 1e2 observations on Intel i5-6200U
## 5.14 hrs on Intel i7
res <- subplex(par = init_par, fn = objective_fun, data = dmi)
str(res)
round(res$par, 2)  ## remember to check res$convergence

save(res, dat, p.vector, file = "LCA1S_MLE_1e2_subplex.RData")
save(res, dat, p.vector, file = "LCA1S_MLE_1e3_subplex.RData")

##      kappa    beta       Z     t0   I.true  I.false      x0    
## True  1.15      1     0.5    0.20     1.2        1      .15
## 1e2  0.77    0.33    0.64    0.06    0.83     0.83     0.33 
## 1e3  0.33    0.92    0.37    0.32    0.53     0.53     0.14  

``` 
