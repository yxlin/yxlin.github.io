# Cognitive Models

This is the tutorial site for the software, [ggdmc](https://github.com/yxlin/ggdmc/).

The package, evolving from dynamic model of choice (_DMC_,
Heathcote, Lin, et al., 2018), is a generic tool for conducting Bayesian 
MCMC on cognitive models, with a specific emphasis on the challenging 
hierarchical models and likelihood-free methods.

1. Instead of using Gibbs or HMC, **_ggdmc_** uses population-based MCMC (pMCMC) 
samplers. A notable Gibbs example is the Python-based 
HDDM (Wiecki, Sofer & Frank, 2013), which does not allow the user to 
conveniently set the variability parameter in the diffusion decision model (DDM). 

2. Differing from DMC (Heathcote, Lin, et al., 2018), with only the DE-MCMC 
(Turner, Sederberg, Brown, & Steyvers, 2013) sampler, **_ggdmc_** provides a 
number of different pMCMC samplers. It is up to the user to 
decide which sampler works best for their models. DE-MCMC is good for models
with moderate number of parameters, (less than 10), but may find it
challenging for complex models.

3. **_ggdmc_** uses a different variant of _migration_ operator, which safeguards
the detailed balance. It is not imperative to turn off the _migration_ operator. 
But one might still consider to turn it off, because it is essentially a 
sampler, similar to random-walk Metropolis, which is very inefficient when
it works alone.  Mostly, pMCMC is efficient when a combination of 
operatoers is applied together. **_ggdmc_** records rejection rates, allowing
the user to monitor a sampler's performance. 

### Getting Started

Here is a quick getting start guide:

1. Download **_ggdmc_** from [CRAN](https://cran.r-project.org/web/packages/ggdmc/index.html).
2. [Windows only] Install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) to compile
C++ codes in **_ggdmc_**.
3. Install the package using install.packages function :

> install.packages("ggdmc")

using devtools via GitHub 

> devtools::install_github("yxlin/ggdmc")

or using source tarball you have downloaded from CRAN (or from _click here_)

> install.packages("ggdmc_0.2.6.0.tar.gz", repos = NULL, type="source")
