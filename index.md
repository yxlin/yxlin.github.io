---
title: 
---
This is the tutorial site for the software, [ggdmc](https://github.com/yxlin/ggdmc/).

The package, evolving from dynamic model of choice (_DMC_,
Heathcote, Lin, et al., 2018), is a generic tool for conducting Bayesian Computations 
on cognitive models, with a specific emphasis on the challenging hierarchical models
and likelihood approximation methods.

1. Instead of using Gibbs or HMC, **_ggdmc_** uses population-based MCMC (pMCMC) 
samplers. A notable Gibbs example is the Gibbs-based Python software,
HDDM (Wiecki, Sofer & Frank, 2013), which fit the Wiener diffusion model.
This specific diffusion model presumes no variability at the starting point
and drift rates.

2. An HMC example aiming for conducting Bayesian RT models is Ahn, Haines, and
Zhang's _hBayesDM_, which is an R package providing convenient wrapper functions
for the well-known Stan software. That is, the user needs to write their own Stan
codes or modify the DDM / LBA Stan codes, packaged together in _hBayesDM_ for
the specific models / probability density functions, even just a change in
the experimental design. This has been considered in the design of _DMC_
(Heathcote et al., 2018), which _ggdmc_ also includes, is that we provide a
convenient interface to allow the user to fit many, if not all, different
experimental designs of, for instance, DDM and LBA model.

3. **_ggdmc_** uses two different variants of _migration_ operator in addition to
the crossover operator.

### Getting Started

Here is a quick getting start guide:

#### Installation

1. Download **_ggdmc_** from [CRAN](https://cran.r-project.org/web/packages/ggdmc/index.html),
[GitHub](https://github.com/yxlin/ggdmc).
2. [Windows only] Install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) to compile
C++ codes in **_ggdmc_**.
3. Install the package:

> install.packages("ggdmc")

or from GitHub 

> devtools::install_github("yxlin/ggdmc")

or from source tarball. You can email me at, <yishinlin001@gmail.com>
to request a free copy of the latest software)

> install.packages("ggdmc_0.2.6.0.tar.gz", repos = NULL, type="source")

#### Load _ggdmc_ Package

> require(ggdmc)

#### FAQ






