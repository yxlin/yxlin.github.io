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

# Getting Started

Here is a quick getting start guide:

## Installation

1. Download **_ggdmc_** from [CRAN](https://cran.r-project.org/web/packages/ggdmc/index.html), or
[GitHub](https://github.com/yxlin/ggdmc).
2. [Windows only] Install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) to compile
C++ codes in **_ggdmc_**.
3. Install the package:

> install.packages('ggdmc')

or from GitHub 

> devtools::install_github('yxlin/ggdmc')

or from source tarball. 

> install.packages('ggdmc_0.2.6.0.tar.gz', repos = NULL, type='source')

## FAQ
1. I cannot install the package on Microsoft R. 
   
   As of January 6, 2020, users deploying 'ggdmc' on Microsoft R (which uses R version 3.5.3) may encounter two issues:

   * **RcppArmadillo incompatibility**: The RcppArmadillo package on MRAN is outdated compared to the version on CRAN. This means it lacks recent Armadillo functions like randperm in C++. To resolve this, install RcppArmadillo directly from its source code on CRAN.
   * **Package installation issues**: The default Windows installation process seeks a package binary matching the local R version. Since Microsoft R uses R 3.5.3, it may fail to find a suitable ggdmc package. To overcome this, install ggdmc from its source code as well.

2. All three methods of the installation fail in my computer. 
   
   Installation problems can arise due to changes in supporting software. Luckily, most can be fixed by installing from the source code. Here's a recommended installation order (choose the method that suits your comfort level)

   * **Simplest Method (For New Users): Install from CRAN**

    This method installs the official version (0.2.6) directly from the Comprehensive R Archive Network (CRAN). It's the easiest option and still worked on a Windows 11 computer.

   * **More Control (Requires R Packaging Knowledge): Install from Source**

    This method lets you install a newer custom-built version (0.2.8.1) from the source code on GitHub. However, it requires some familiarity with R packaging. Pre-packaged installation files are available on the project's [documentation](https://github.com/yxlin/ggdmc/tree/master/docs).

    Note: RStudio usually finds RTools automatically, which is necessary for this method on a Windows machine. If you use a different IDE, you might need to configure it to locate RTools tools.

   * **Advanced Users (May Require Additional Packages): Install with devtools**

    This method uses 'devtools' to install 'ggdmc' directly from GitHub. While convenient, it might install extra packages that have nothing to do with 'ggdmc'. You must install all the 'devtools' dependencies, which may require their own dependencies.

    

