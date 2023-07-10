# Load packages -------------------------------------------------------------------------
library(foreach)
library(doParallel)

# Housekeeping -------------------------------------------------------------------------
system("rm *.out")
system("rm -rf outputs")
dir.create("outputs")

# Compile model code -----------------------------------------------------------
file.remove("mcsim.butadiene.model.exe")
model <- "butadiene.model"
RMCSim::makemcsim(model = model, mxstep = 5000, dir = "MCSim")

# Choose input file ------------------------------------------------------------
input <- "butadiene.mcmc.in" 

# MCMC -------------------------------------------------------------------------
current_files <- list.files()
cores <- 3    # 3 chains
cl <- makeCluster(cores)
registerDoParallel(cl)

out <- foreach(i = 1:cores) %dopar% {
  set.seed(i + 1)
  RMCSim::mcsim(model = model, input = input, dir = "MCSim", parallel = T)
}

new_files <- setdiff(list.files(), current_files)
to_remove <- new_files[grep(".kernel|.in", new_files)]
file.remove(to_remove)
out_files <- setdiff(list.files(), current_files)

for (i in 1:length(out_files)) file.copy(out_files[i], paste0("outputs/", out_files[i]))
file.remove(out_files)
