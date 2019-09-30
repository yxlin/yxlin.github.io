---
title: Migration
category: Sampling Techniques
order: 3
---

_Migration_ operator is one crucial operator in the distributed genetic
algorithm (Tanese, 1989; Hu & Tsai, 2005), originated from the genetic
algorithm (Holland, 1975; Goldberg, 1989). The algorithm uses a similar
scheme, like chromosomes exchange gene information.

_Migration_ in MCMC computation uses the same method as in random-walk
Metropolis to propose a new _proposal_, which is then subjected to the
Metropolis decision step to accept or reject as a valid sample from a
target distribution.  The method of _migration_ operator to propose
a proposal is that it adds random noise vector onto a "current"
parameter vector as a new _proposal_.


