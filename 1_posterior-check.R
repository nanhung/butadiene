library(data.table) # fread
library(purrr) # map
library(rstan) # monitor

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

j <- 502:1001
mnt <- monitor(x[j, , pars_name[-1]], digit = 6, print = T)

df <- read.delim("outputs/butadiene_check_6734.out")
plot(df$Data, df$Prediction)
abline(0,1)

save_directory <- "outputs"
file_name <- paste("MCMCfinal_", format(Sys.time(), "%Y-%m-%d"), ".RData", sep = "")
k <- 2:19
pars <- pars_name[2:19]
final <- x[j, , pars]
l <- dim(final)[1] * dim(final)[2]
dim(final) <- c(l, length(pars))
colnames(final) <- pars
save(final, file = file.path(save_directory, file_name))
