---
layout: home
title: "Cognitive Models with ggdmc"
---


The [**ggdmc**](https://github.com/yxlin/ggdmc/) R package provides tools and tutorials for **cognitive modelling**, supporting both **Bayesian** and **non-Bayesian** approaches. Evolving from *Dynamic Models of Choice* (DMC; Heathcote, Lin, et al., 2018), **ggdmc** targets challenging **hierarchical** and **likelihood-free** problems while remaining friendly for conventional modelling workflows.

> **Latest release: v0.2.9.0** — expanded hierarchical tools, improved samplers, and better monitoring for model fitting.

---

## 🚀 What’s new in v0.2.9.0

- **Parallel chain instances for hierarchical models**  
  By default, hierarchical fits now launch **three independent chain instances**, each running a **swarm of chains** (≈ 3× the number of parameters) to improve posterior exploration and guard against cross-chain dependence.

- **Sampler & monitoring improvements**  
  More robust defaults and clearer diagnostics for convergence and mixing.

- **Richer hierarchical controls**  
  Cleaner parameter control plus more flexible variability settings for **DDM**, **LBA**, and **CDM**.

- **Migration & blocking options**  
  Enable migration and blocking at **subject** and/or **population** levels to speed convergence on complex factorial designs.

---

## ✨ Key Features

1. **Population-based MCMC (pMCMC)**  
   Multiple interacting chains for efficient exploration of complex posteriors.

2. **Multiple samplers, parallelized**  
   Compare/choose samplers; parallel chain instances provide independence checks and efficiency.

3. **Flexible sampling strategies**  
   Migration operators and blocking at different hierarchy levels.

4. **Broader model coverage**  
   Enhanced support for hierarchical **DDM**, **LBA**, and **CDM**, with clearer variability controls.

---

## 📦 Installation

### CRAN (stable) or source tarball
```r
install.packages("ggdmc")
# Or a specific release tarball:
install.packages("ggdmc_0.2.9.0.tar.gz", repos = NULL, type = "source")
```

## GitHub (development)

```r
# Requires devtools
install.packages("devtools")
devtools::install_github("yxlin/ggdmc")
```

- **Windows**: Install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) to compile C++.
- **macOS**: Install Xcode Command Line Tools.
- **Linux**: Ensure a recent compiler toolchain is available.


## 🧭 Quick start

```r
library(ggdmc)

# 1) Specify a model (e.g., LBA/DDM/CDM) and priors
# 2) Build a data-model instance (DMI)
# 3) Configure pMCMC (chains, instances, migration/blocking)
# 4) Run sampler, monitor convergence, and examine posterior summaries
```

<details>
<summary>🔬 Advanced Example: CDM simulation & hierarchical fitting (click to expand)</summary>

```r
# Example workflow: build, simulate, fit
pkg <- c("ggdmc", "ggdmcPrior", "ggdmcModel", "cdModel")
sapply(pkg, require, character.only = TRUE)

# Build a CDM model
model <- BuildModel(
  p_map = list(guess1="1", guess2="1", guess3="1",
               slip1="1", slip2="1", slip3="1"),
  type = "cdm"
)

# Define population priors
pop_mean <- c(guess1=.1, guess2=.2, guess3=.3,
              slip1=.01, slip2=.02, slip3=.03)
pop_scale <- c(guess1=.01, guess2=.01, guess3=.01,
               slip1=.05, slip2=.01, slip3=.01)
pop_dist <- ggdmcPrior::BuildPrior(
  p0=pop_mean, p1=pop_scale,
  lower=rep(0, model@npar),
  upper=rep(NA, model@npar),
  dists=rep("tnorm", model@npar),
  log_p=rep(FALSE, model@npar)
)

# Set CDM models
sub_model <- setCDM(model)
pop_model <- setCDM(model, population_distribution=pop_dist)

# Simulate data
dat <- simulate(sub_model, nsim=1000,
                parameter_vector=pop_mean, nschool=1, seed=123)
hdat <- simulate(pop_model, nsim=1000, nschool=32, seed=123)

# Build DMIs
sub_dmis <- BuildDMI(dat$responses, model, q_matrix=sub_model@q_matrix, rule="DINA")
pop_dmis <- BuildDMI(hdat$responses, model, q_matrix=pop_model@q_matrix, rule="DINA")

# Priors and initial samples
p0 <- rep(0, model@npar); names(p0) <- model@pnames
p_prior <- ggdmcPrior::BuildPrior(p0=p0, p1=rep(1.1, model@npar),
                                  dist=rep("unif", model@npar), log_p=rep(TRUE, model@npar))
sub_priors <- set_priors(p_prior=p_prior)
sub_theta_input <- ggdmc::setThetaInput(nmc=500, pnames=model@pnames)
sub_samples <- initialise_theta(sub_theta_input, sub_priors, sub_dmis[[1]])

# Run sampling
fits <- StartSampling_subject(sub_dmis[[1]], sub_priors,
                              sub_migration_prob=0.02, thin=2, seed=9032)
fit <- RebuildPosterior(fits)
hat <- gelman(fit)
cat("mpsrf = ", hat$mpsrf, "\n")
```

</details>


## ❓ FAQ

**Q1. Installation issues on older R / Microsoft R**  
- `RcppArmadillo` may be outdated — install the latest from CRAN.  
- If no binary is available, install from source (Rtools on Windows; Xcode on macOS).  

**Q2. All install methods fail?**  
Try in this order:  
1. CRAN (stable)  
2. GitHub (development)  
3. Source tarball with toolchain (Rtools/Xcode/GCC/Clang)  

---

## 🔗 Useful Links
- [GitHub Source & Issues](https://github.com/yxlin/ggdmc)  
- DMC Reference: Heathcote, Lin, et al. (2018)  
- Related packages/tutorials: see repository README and vignettes  

---

**ggdmc** continues to evolve to meet research needs in psychology, cognitive science, and education — especially for **hierarchical Bayesian** and **large-scale applications**.


