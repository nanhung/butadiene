# Install packages-------------------------------------------------------
if (require(RMCSim)) remove.packages("RMCSim")
remotes::install_github("nanhung/RMCSim")

library(RMCSim)
install_mcsim(version = "6.1.0")
mcsim_version()

pkgs <- c("foreach", "doParallel", "data.table", "purrr", 
          "rstan", "tidyr", "dplyr", "ggplot2")
install.packages(pkgs)