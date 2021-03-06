rm(list = ls())

predict_one <- function(object, npost = 100, xlim = NA, seed = NULL)
{
    facs   <- attr(object@dmi@model, "factors"); 
    fnames <- names(facs); 
    ns <- table( object@dmi@data[, fnames], dnn = fnames)
    nsample <- object@nchain * object@nmc; 
    pnames <- object@pnames; 

    thetas <- matrix(aperm(object@theta, c(3,2,1)), ncol = object@npar)
    colnames(thetas) <- pnames
  
    if (is.na(npost)) stop("Must specify npost!")
    
    use <- sample(1:nsample, npost, replace = FALSE); 
    npost  <- length(use)
    posts   <- thetas[use, ]
    ntrial <- sum(ns) 
    v <- lapply(1:npost, function(i) {
        simulate(object@dmi@model, nsim = ns, ps = posts[i,], seed = seed)
    })
    out <- data.table::rbindlist(v)
    reps <- rep(1:npost, each = ntrial)
    out <- cbind(reps, out)
  
    if (!any(is.na(xlim))) out <- out[RT > xlim[1] & RT < xlim[2]]
    attr(out, "data") <- object@dmi
    return(out)
}


loadedPackages <-c("ggdmc", "data.table", "ggplot2", "gridExtra", "ggthemes")
sapply(loadedPackages, require, character.only=TRUE)

model <- BuildModel(
  p.map     = list(A = "1", B = "1", t0 = "1", mean_v = "R", sd_v = "1",
                   st0 = "1"),
  match.map = list(M = list(ww = "W", nn = "N", pn = "P")),
  factors   = list(S = c("ww", "nn", "pn")),
  constants = c(st0 = 0, sd_v = 1),
  responses = c("W", "N", "P"),
  type      = "norm")

p.vector <- c(A = 1.25, B = .25, t0 = .2, mean_v.W = 2.5, mean_v.N = 1.5,
              mean_v.P = 1.2)

## ggdmc adapts print function to help inspect model
print(model)


nsim <- 2048
dat <- simulate(model, nsim = nsim, ps = p.vector)
d <- data.table(dat)
dmi <- BuildDMI(dat, model)

## Check the factor levels
sapply(d[, .(S,R)], levels)

ww1 <- d[S == "ww" & R == "W" & RT <= 10, "RT"]
ww1 <- d[S == "ww" & R == "W" & RT <= 10, "RT"]
ww2 <- d[S == "ww" & R == "N" & RT <= 10, "RT"]
ww3 <- d[S == "ww" & R == "P" & RT <= 10, "RT"]
nn1 <- d[S == "nn" & R == "W" & RT <= 10, "RT"]
nn2 <- d[S == "nn" & R == "N" & RT <= 10, "RT"]
nn3 <- d[S == "nn" & R == "P" & RT <= 10, "RT"]
pn1 <- d[S == "pn" & R == "W" & RT <= 10, "RT"]
pn2 <- d[S == "pn" & R == "N" & RT <= 10, "RT"]
pn3 <- d[S == "pn" & R == "P" & RT <= 10, "RT"]

xlim <- c(0, 5)
par(mfrow=c(3, 1), mar = c(4, 4, 0.82, 1))
hist(ww1$RT, breaks = "fd", freq = TRUE, xlim = xlim, main='Word', xlab='RT(s)',
     cex.lab=1.5)
hist(ww2$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "lightblue")
hist(ww3$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "orange")

hist(nn1$RT, breaks = "fd", freq = TRUE, xlim = xlim, main='Non-word', 
     xlab='RT(s)', ylab='', cex.lab=1.5)
hist(nn2$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "lightblue")
hist(nn3$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "orange")

hist(pn1$RT, breaks = "fd", freq = TRUE, xlim = xlim, main='P-word', 
     xlab='RT(s)', ylab='', cex.lab=1.5)
hist(pn2$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "lightblue")
hist(pn3$RT, breaks = "fd", freq = TRUE, add = TRUE, col = "orange")
par(mfrow=c(1, 1))

p.prior <- BuildPrior(
  dists = c("tnorm", "tnorm", "beta", "tnorm", "tnorm", "tnorm"),
  p1    = c(A = .3, B = 1, t0 = 1,
            mean_v.W = 1, mean_v.N = 0, mean_v.P = .1),
  p2    = c(1, 1,   1,  3, 3, 3),
  lower = c(0, 0,   0, NA, NA, NA),
  upper = c(NA, NA, 1, NA, NA, NA))

plot(p.prior, ps = p.vector)

fit0 <- StartNewsamples(dmi, p.prior, thin = 2)
fit <- run(fit0, thin = 2, block = FALSE)


p1 <- plot(fit)
p2 <- plot(fit, pll=F, den=T)
p3 <- plot(fit, subchain = TRUE)
p4 <- plot(fit, pll=F, den=T, subchain = TRUE)

png(file = "LBA3A-checks.png", 800, 600)
grid.arrange(p1, p2, p3, p4)
dev.off()




res <- gelman(fit, verbose = TRUE)
res <- gelman(fit, verbose = TRUE, subchain = 1:3)
es <- effectiveSize(fit, verbose = TRUE)
est <- summary(fit, ps = p.vector, verbose = TRUE, recovery = TRUE)
## Recovery summarises only default quantiles: 2.5% 25% 50% 75% 97.5% 
##                     A       B mean_v.N mean_v.P mean_v.W     t0
## True           1.2500  0.2500   1.5000   1.2000   2.5000 0.2000
## 2.5% Estimate  1.1516  0.2153   1.3745   1.0190   2.3058 0.1900
## 50% Estimate   1.2724  0.2495   1.5667   1.2116   2.5075 0.2000
## 97.5% Estimate 1.4053  0.2920   1.7573   1.4070   2.7250 0.2085
## Median-True    0.0224 -0.0005   0.0667   0.0116   0.0075 0.0000


pp <- predict_one(fit, xlim = c(0, 5))

original_data <- fit@dmi@data
dplyr::tbl_df(original_data)
d <- data.table(original_data)

## Response proportions
d[, .N, .(S)]
d[, .N/100, .(S, R)]


## Score for the correct and error response
dat$C <- ifelse(dat$S == "ww" & dat$R == "W", "O",
         ifelse(dat$S == "nn" & dat$R == "N", "O",
         ifelse(dat$S == "pn" & dat$R == "P", "O",
         ifelse(dat$S == "ww" & dat$R == "N", "X",
         ifelse(dat$S == "ww" & dat$R == "P", "X",
         ifelse(dat$S == "nn" & dat$R == "W", "X",
         ifelse(dat$S == "nn" & dat$R == "P", "X",
         ifelse(dat$S == "pn" & dat$R == "N", "X",
         ifelse(dat$S == "pn" & dat$R == "W", "X", NA)))))))))

pp$C <- ifelse(pp$S == "ww" & pp$R == "W", "O",
        ifelse(pp$S == "nn" & pp$R == "N", "O",
        ifelse(pp$S == "pn" & pp$R == "P", "O",
        ifelse(pp$S == "ww" & pp$R == "N", "X",
        ifelse(pp$S == "ww" & pp$R == "P", "X",
        ifelse(pp$S == "nn" & pp$R == "W", "X",
        ifelse(pp$S == "nn" & pp$R == "P", "X",
        ifelse(pp$S == "pn" & pp$R == "N", "X",
        ifelse(pp$S == "pn" & pp$R == "W", "X", NA)))))))))


dat0 <- dat
dat0$reps <- NA
dat0$type <- "Data"
pp$reps <- factor(pp$reps)
pp$type <- "Simulation"
combined_data <- rbind(dat0, pp)

dplyr::tbl_df(combined_data)

p1 <- ggplot(combined_data, aes(RT, color = reps, size = type)) +
  geom_freqpoly(binwidth = .10) +
  scale_size_manual(values = c(1, .3)) +
  scale_color_grey(na.value = "black") +
  ylab("Count") +
  facet_grid(S ~ C) +
  theme_bw(base_size = 16) +
  theme(strip.background = element_blank(),
        legend.position="none") 

png(file = "LBA3A.png", 800, 600)
print(p1)
dev.off()
