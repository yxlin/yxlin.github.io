# Cognitive Models

This is the tutorial site for the software, [ggdmc](https://github.com/yxlin/ggdmc/).

The package, evolving from dynamic model of choice (_DMC_,
Heathcote, Lin, et al., 2018), is a generic tool for conducting cognitive 
models, Bayesian or non-Bayesian. The software emphasize on the challenging 
hierarchical and likelihood-free modelling, but nontheless, it can work with the
conventional modelling method, too.

1. Instead of using Gibbs or HMC, **_ggdmc_** uses population-based MCMC (pMCMC) 
samplers. A notable Gibbs example is the Python-based HDDM 
(Wiecki, Sofer & Frank, 2013), which does not allow the user to 
conveniently set the variability parameter in the diffusion decision model 
(DDM). Note we do not argue for or against which of the sampling techniques is
better than others, but simply provide an alternative choice. pMCMC is 
very differernt other sampling techniques, because it harnesses a large number 
of chains to improve sampling efficency.     

2. Differing from DMC (Heathcote, Lin, et al., 2018), with only the DE-MCMC 
(Turner, Sederberg, Brown, & Steyvers, 2013) sampler, **_ggdmc_** provides a 
number of different pMCMC samplers. It is up to the user to decide which sampler
works best for their models. 

3. **_ggdmc_** uses a different variant of _migration_ operator, which safeguards
the detailed balance. These are provided via the _pm0_ and _pm1_ options in 
the model fitting routines. It is not imperative to turn on/off the _migration_ 
operator. But one might still consider to turn it off, because they are 
essentially a sampler, similar to random-walk Metropolis, which are not  
efficient when they works alone.  Mostly, pMCMC is efficient when a combination
of operatoers is applied together. **_ggdmc_** records rejection rates, 
allowing the user to monitor a sampler's performance. 

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
