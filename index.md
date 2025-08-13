---
title: 📦 ggdmc
---


# Cognitive Models

This site provides tutorials for the [**ggdmc**](https://github.com/yxlin/ggdmc/) R package.  

**ggdmc** is an open-source toolkit for conducting cognitive modelling, supporting both Bayesian and non-Bayesian approaches. Evolving from the *Dynamic Models of Choice* (DMC; Heathcote, Lin, et al., 2018), the package is designed to address challenging **hierarchical** and **likelihood-free** modelling problems, while still accommodating more conventional modelling workflows.  

The latest release (**v0.2.8.9**) introduces expanded functionality, improved sampler options, and enhanced monitoring tools for model fitting.

---

## Key Features

1. **Population-based MCMC (pMCMC) sampling**  
   **ggdmc** implements **population-based MCMC** samplers, which run multiple interacting chains in parallel to improve sampling efficiency.  
   This approach provides an alternative to single-chain samplers and can offer better exploration of complex posterior landscapes in some modelling scenarios.

2. **Multiple pMCMC samplers with parallel chain instances**  
   - **ggdmc** now offers a broader set of samplers, giving users the flexibility to choose or compare methods for different models.  
   - Version 0.2.8.9 introduces a new *parallel chain instance* concept. By default, hierarchical model fitting launches **three independent chain instances**. Within each instance, a **swarm of chains** (three times the number of parameters) is used to enable pMCMC to work effectively.  
   - This design addresses the issue of non-independence in traditional pMCMC while also improving computational efficiency.

3. **Flexible migration operator and blocking mechanism**  
   - Users can enable migration sampling or apply a blocking mechanism at the **subject level**, **population level**, or both.  
   - This flexibility allows the sampling strategy to be adapted for different model types and factorial designs, improving both convergence and efficiency.

4. **Expanded model support and hierarchical tools** *(v0.2.8.9)*  
   - Improved hierarchical model handling with clearer parameter control.  
   - More flexible parameter variability settings for DDM and LBA.

---

## Getting Started

### Installation

#### From CRAN or source tarball
```r
install.packages("ggdmc")
install.packages("ggdmc_0.2.8.9.tar.gz", repos = NULL, type = "source")

```

### From GitHub (development version)
```r
# Requires devtools
install.packages("devtools")
devtools::install_github("yxlin/ggdmc")
```

> **Windows users**: Install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) to compile C++ code.  
> **macOS users**: Ensure Xcode Command Line Tools are installed.

---

## ❓ FAQ

### 1. Installation fails on Microsoft R  
Microsoft R (v3.5.3) may cause issues due to outdated dependencies:  
- **RcppArmadillo incompatibility**: Install the latest version directly from CRAN.  
- **Binary availability**: If a precompiled binary is unavailable, install **ggdmc** from source.

### 2. All installation methods fail  
Try installing from source in the following order:  
- **Easiest**: Install from CRAN (stable release).  
- **More control**: Install from GitHub (development version).  
- **Advanced**: Compile from source tarball with Rtools (Windows) or Xcode tools (macOS/Linux).

