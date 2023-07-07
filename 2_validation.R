library(RMCSim)

MCMC_file_to_be_load <- list.files(paste0("./outputs/"), pattern='MCMC')
load(paste0("outputs/",MCMC_file_to_be_load))
parms <- colnames(mcmc_out)
parms

# subject1
i <- sample(dim(mcmc_out)[1], 100)
j <- 19:27
tmp.x <- mcmc_out[i, parms[j]] 
tmp.x %>% write.table(file="subject01.dat", row.names=T, sep="\t")

model <- "butadiene.model"
input <- "butadiene.subject01.in" 
mcsim(model = model, input = input, dir = "MCSim")

#pop
j <- 1:18
tmp.x <- mcmc_out[i, parms[j]] 
tmp.x %>% write.table(file="poppred.dat", row.names=T, sep="\t")
input <- "butadiene.poppred.in" 
mcsim(model = model, input = input, dir = "MCSim")

