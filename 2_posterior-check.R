# Load packages -------------------------------------------------------------------------
library(data.table) # fread
library(purrr) # map
library(rstan) # monitor
library(ggplot2)

out <- c("outputs/butadiene_6734.out",
         "outputs/butadiene_4880.out",
         "outputs/butadiene_5916.out")

data <- out |> map(fread) |> map(as.data.frame)

n_chains <- length(data)
sample_number <- dim(data[[1]])[1]
dim <- c(sample_number, n_chains, dim(data[[1]])[2])
n_iter <- dim(data[[1]])[1]
n_param <- dim(data[[1]])[2]
x <- array(sample_number:(n_iter * n_chains * n_param), dim = dim)
for (i in 1:n_chains) {
  x[, i, ] <- as.matrix(data[[i]][1:n_iter, ])
}
dimnames(x)[[3]] <- names(data[[1]])

pars_name <- dimnames(x)[[3]]

# Posterior check
j <- 502:1001
mnt <- monitor(x[j, , pars_name[-1]], digit = 6, print = T)

save_directory <- "outputs"
file_name <- paste("MCMCfinal_", format(Sys.time(), "%Y-%m-%d"), ".RData", sep = "")
k <- c(2:19, 21:29) # pop_M, pop_V and individual 1
pars <- pars_name[k]
mcmc_out <- x[j, , pars]
l <- dim(mcmc_out)[1] * dim(mcmc_out)[2]
dim(mcmc_out) <- c(l, length(pars))
colnames(mcmc_out) <- pars
save(mcmc_out, file = file.path(save_directory, file_name))

# Plot
x <- read.delim("outputs/butadiene_check_6734.out")
pdf(file = "outputs/validation.pdf", width = 9, height = 9)
ggplot(data = x) + geom_point(aes(x=Data, y=Prediction)) + geom_abline(slope = 1)
dev.off()