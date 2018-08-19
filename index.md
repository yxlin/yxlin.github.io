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
This specific diffusion model presume no variability at the starting point
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

3. Differing from _DMC_ (Heathcote, Lin, et al., 2018), with only the DE-MCMC 
(Turner, Sederberg, Brown, & Steyvers, 2013) sampler, **_ggdmc_** provides a number 
of different pMCMC samplers. It is up to the user to 
decide which sampler works best for their models. DE-MCMC is good for models
with moderate number of parameters, (less than 10), but may find it
challenging for complex models.

4. **_ggdmc_** uses a different variant of _migration_ operator, which safeguards
the detailed balance. It is not imperative to turn off the _migration_ operator. 
But one might still consider to turn it off, because it is essentially a 
sampler, similar to random-walk Metropolis, which is very inefficient when
it works alone.  Mostly, pMCMC is efficient when a combination of 
operators is intelligently applied together. **_ggdmc_** records rejection rates,
allowing the user to monitor a sampler's performance. 

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

or from source tarball. You can email me at, <yishin.lin@utas.edu.au>
to request a copy of the software for FREE!)

> install.packages("ggdmc_0.2.3.7.tar.gz", repos = NULL, type="source")

#### Load _ggdmc_ Package

> require(ggdmc)

#### FAQ

#### Advertisement

!!!Warning!!! This is an advertisement

I am looking for a job! If you are interested in my Bayesian software here and / or
my [CUDA C software](https://github.com/TasCL/ppda), please get in touch with me.



