# In this script, for each chemical-readout pair,
# SHARP test is repeated 20 times

rm(list = ls())
library(here)
library(tidyverse)
library(Kendall)
library(PMCMRplus)
library(scales)
library(SRMERS)
library(kableExtra)
library(knitr)
library(doParallel)
# library the current package
theme_set(theme_minimal())

set.seed(42)

# load data
norm_resp <- read_tsv("Data/botanical_norm_resp.tsv", col_types = cols())


# indexes
## index one chemical
# k <- commandArgs(trailingOnly = TRUE)
# k <- as.numeric(k)
k <- 1
chems <-sort(unique(norm_resp$sample_id))
chem_k <- chems[k]
## readouts
outs <- sort(unique(norm_resp$protocol_readout))

# rename
curve_k <- norm_resp %>%
  rename(chem=sample_id, out=protocol_readout) %>%
  filter(chem==chem_k) %>%
  group_by(out, batch) %>%
  mutate(resps = scale(resps, center=T, scale=T)[,1]) %>%
  mutate(concs = log(concs))

#### Repeat SHARP ####

nRep <- 21
RepPvalList <-list()
time_test <- rep(NA, length(outs))

for(i in seq_along(outs)){

  # subset datafor one readout
  curve_ki <- curve_k %>% filter(out==outs[i])

  # repeat SHARP test
  time_i <- system.time({
    pvals_i <- lapply(1:nRep, function(r){
      SHARPtest(df=curve_ki, mixed=F, xName="concs", yName="resps", niter=1000)})
  })

  # result
  RepPvalList[[outs[i]]] <- bind_rows(pvals_i, .id="Rep")
  time_test[i] <- time_i[3]/60

  print(paste0(chem_k, " & ", outs[i], " completed. Time: ", round(mean(time_test[i]), 2), " min"))
}


# save result
# output_chem_k <- bind_rows(RepPvalList, .id="Readout")
# filename <- paste0("Output/", chem_k, ".RData")
# save(output_chem_k, file = here(filename))


