# Cognitive Models with ggdmc

The [`ggdmc`](https://github.com/yxlin/ggdmc/) R package provides tools and tutorials for **cognitive modelling**, supporting both **Bayesian** and **non-Bayesian** approaches.

Originally developed from the Dynamic Models of Choice framework (DMC; Heathcote, Lin, et al., 2018), **ggdmc** is designed to tackle **hierarchical** and **likelihood-free** modelling problems, while still supporting conventional modelling workflows used by experimental psychologists and behavioural scientists.

-----

## 🚀 What’s New in v0.2.9.0

- **Expanded hierarchical model tools**
  - Clearer parameter control for hierarchical designs.
  - Flexible parameter variability settings for the **Diffusion Decision Model (DDM)**, **Linear Ballistic Accumulation (LBA)** Model.
  - New genre of model, **Cognitive Diagnostic Model**.

- **Improved sampling and monitoring**
  - New sampler options with more robust defaults.
  - Enhanced monitoring functions for diagnosing convergence and chain mixing.
  - 
- **Parallel chain instances for hierarchical models**
  - By default, parameter optimisation now run multiple swarms of chains, resulting in true theoretically independent instances.
  - Each instance launches **a swarm of chains** (3× the number of parameters), giving better exploration of the posterior space.
  
- **Migration operator & blocking mechanism**
  - Migration sampling can now be applied at the subject or population level.
  - Blocking mechanisms allow for efficient updates in complex factorial designs.

------

## ✨ Key Features

1. **Population-based MCMC (pMCMC) sampling**
   - Multiple interacting chains utilising the idea of genetic evoltuion for efficient sampling.
   - Better exploration of complex posteriors compared to single-chain samplers.

2. **Multiple pMCMC samplers**
   - Choose between different sampler types to match your model and data.
   - The new parallel chain instance design improves both independence and computational speed.

3. **Flexible sampling strategies**
   - Enable migration operators or blocking at different levels (subject, population, or both).
   - Adaptable to hierarchical designs, factorial experiments, and large-scale datasets.

4. **Broader model support**
   - Enhanced native support for hierarchical DDM, LBA, and CDM.
   - Improved parameter variability handling for custom model specifications.
   - For customised model, please see [`ppda`](https://github.com/yxlin/ppda) Github page for pLBA model.

## 📦 Installation

From CRAN or source tarball
```r

install.packages("ggdmc")

# Or install a specific release
install.packages("ggdmc_0.2.9.0.tar.gz", repos = NULL, type = "source")
```

From GitHub (development version)

```r
# Requires devtools
install.packages("devtools")
devtools::install_github("yxlin/ggdmc")

```

## 📖 Learn More
Visit the tutorials on this site to explore:
- How to specify models and parameters
- How to run hierarchical Bayesian inference
- How to monitor, diagnose, and interpret results