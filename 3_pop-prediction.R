# Load packages -------------------------------------------------------------------------
library(RMCSim)
library(tidyr)
library(dplyr)
library(ggplot2)

MCMC_file_to_be_load <- list.files(paste0("./outputs/"), pattern='MCMC')
load(paste0("outputs/",MCMC_file_to_be_load))
parms <- colnames(mcmc_out)

# subject1
i <- sample(dim(mcmc_out)[1], 100) # random select 100 draws
j <- 19:27
tmp.x <- mcmc_out[i, parms[j]] 
tmp.x |> write.table(file="subject01.dat", row.names=T, sep="\t")

model <- "butadiene.model"
input <- "butadiene.subject01.in" 
mcsim(model = model, input = input, dir = "MCSim")

pred_subject01 <- read.delim("subject01.out") |> as.data.frame()
str <- which(names(pred_subject01) == "C_exh_1.1")
end <- which(names(pred_subject01) == "C_exh_1.12")
time <- c(0.5, 1, 2, 5, 10, 15, 19, 21, 22, 28, 38, 58)
df_pred_subject01 <- pred_subject01[str:end] |> 
  gather() |> cbind(rep(time, each = 100)) |>
  cbind(c(1:100)) |> cbind("ind01_pred") |> 
  `colnames<-`(c("Var", "C_exh", "Time", "iter", "measurment")) |> 
  select(c("Time", "C_exh", "iter", "measurment"))
df_pred_subject01$iter <- as.factor(df_pred_subject01$iter)

# Pop
j <- 1:18
tmp.x <- mcmc_out[i, parms[j]] 
tmp.x |> write.table(file="poppred.dat", row.names=T, sep="\t")
input <- "butadiene.poppred.in" 
mcsim(model = model, input = input, dir = "MCSim")

pred_pop <- read.delim("poppred.out") |> as.data.frame()
str <- which(names(pred_pop) == "C_exh_1.1")
end <- which(names(pred_pop) == "C_exh_1.12")
df_pred_pop <- pred_pop[str:end] |> 
  gather() |> cbind(rep(time, each = 100)) |>
  cbind(c(1:100)) |> cbind("pop_pred") |> 
  `colnames<-`(c("Var", "C_exh", "Time", "iter", "measurment")) |> 
  select(c("Time", "C_exh", "iter", "measurment"))
df_pred_pop$iter <- as.factor(df_pred_pop$iter)

# Compare subject 1 and population predcition
x <- read.delim("outputs/butadiene_check_6734.out")
df_data_subject01 <- subset(x, Simulation == 1 & Output_Var == "C_exh") |>
  select(c("Time", "Data")) |>
  cbind(1) |> cbind("Subject 1") |> 
  `colnames<-`(c("Time", "C_exh", "iter", "measurment"))

pdf(file = "outputs/pop-prediction.pdf", width = 9, height = 9)
ggplot() + 
  geom_line(data = df_pred_pop, aes(x=Time, y=C_exh, color = measurment, group = iter)) +
  geom_line(data = df_pred_subject01, aes(x=Time, y=C_exh, color = measurment, group = iter)) +
  geom_point(data = df_data_subject01, aes(x=Time, y=C_exh, color = measurment)) +
  scale_color_manual(values= c("pink", "grey40", "darkred")) + 
  theme(legend.position="none")
dev.off()  

# Housekeeping
system("rm *.out *.dat *.exe")
