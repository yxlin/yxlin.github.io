---
title: 
---
This is the tutorial site for the software, [ggdmc](https://github.com/yxlin/ggdmc/).

The package, evolving from dynamic model of choice (_DMC_,
Heathcote, Lin, et al., 2018), is a generic tool for conducting Bayesian Computations 
on cognitive models, with a specific emphasis on the challenging hierarchical
choice response-time models.

1. Instead of using Gibbs or HMC, **_ggdmc_** uses population-based MCMC (pMCMC) 
samplers. A notable Gibbs example for the diffusion model is the Gibbs-based
Python software, HDDM (Wiecki, Sofer & Frank, 2013). This Python-based method
does not have convenient interface to model the parameter variability. We expand
this in our software.

2. An HMC example aiming for conducting hierarchical Bayesian models is Ahn, Haines,
and Zhang's _hBayesDM_, which is an R package providing convenient wrapper functions
for the well-known Stan software. It is a great package and has included interface to
fit models for different cognitive tasks.  However, in _hBayesDM_, the user still needs
to modify their own Stan codes for models when s/he uses different designs, not included
in the package.  _DMC_ expands this function, (Heathcote et al., 2018), so does _ggdmc_.

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

> install.packages('ggdmc')

or from GitHub 

> devtools::install_github('yxlin/ggdmc')

or from source tarball. 

> install.packages('ggdmc_0.2.6.0.tar.gz', repos = NULL, type='source')

#### Load _ggdmc_ Package

> require(ggdmc)

#### FAQ






