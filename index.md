---
title: 📦 ggdmc
---

[![CRAN Status](https://www.r-pkg.org/badges/version/ggdmc)](https://cran.r-project.org/package=ggdmc)  
[![Downloads](https://cranlogs.r-pkg.org/badges/ggdmc)](https://cran.r-project.org/package=ggdmc)  
[![License: GPL-3](https://img.shields.io/badge/license-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)  

This is the tutorial site for the R package **[ggdmc](https://github.com/yxlin/ggdmc/)**.  

**ggdmc** is a flexible and efficient Bayesian modelling toolkit for cognitive models, with a focus on *hierarchical choice response-time models*.  
It evolved from the **Dynamic Models of Choice** framework (_DMC_, Heathcote, Lin, et al., 2018) and is designed for complex model fitting, simulation, and inference.

---

## 🔍 Key Features

1. **Population-based MCMC (pMCMC) Samplers**  
   Unlike traditional Gibbs or HMC approaches, **ggdmc** uses pMCMC methods.  
   - Example: The Python package **HDDM** (Wiecki, Sofer & Frank, 2013) implements Gibbs sampling for the diffusion model, but has limited support for parameter variability. **ggdmc** addresses this limitation with flexible hierarchical structures.

2. **Flexible Model Specification**  
   - In **hBayesDM** (Ahn, Haines & Zhang), hierarchical Bayesian modelling is implemented via Stan, but custom experimental designs often require manual Stan code edits.  
   - **ggdmc** allows you to adapt models to new designs without manually rewriting the underlying C++/Stan code.

3. **Enhanced Evolutionary Operators**  
   - Two migration variants and a crossover operator are available for efficient exploration of the posterior space.

---

## 🚀 Getting Started

### Installation

You can install **ggdmc (v0.2.8.9)** in several ways:

#### 1. From CRAN *(stable release)*  
```r
install.packages("ggdmc")
```

#### 2. From GitHub *(latest development version)*  
```r
install.packages("devtools")  # if not already installed
devtools::install_github("yxlin/ggdmc")
```

#### 3. From a Source Tarball  
```r
install.packages("ggdmc_0.2.8.9.tar.gz", repos = NULL, type = "source")
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


