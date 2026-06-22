rm(list=ls())
ls()

library(rstan)
library(Rcpp)
library(RcppEigen)
library(StanHeaders)
library(BH)
library(inline)
library(plyr)
library(R.matlab)
library(loo)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

script_args <- commandArgs(FALSE)
script_file <- sub("^--file=", "", grep("^--file=", script_args, value = TRUE)[1])
model_dir <- if (!is.na(script_file)) dirname(normalizePath(script_file)) else normalizePath(getwd())
setwd(model_dir)

## Chain number is supplied as a command-line argument, e.g. Rscript RL.R 1
args <- commandArgs(trailingOnly = TRUE);
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else {
  chainNum <- args[1];
}

allParticipantBehavior <- readMat(file.path(model_dir, "estimate_data.mat"));

Group_Choice  = allParticipantBehavior$group.Choice;
Group_Reward    = allParticipantBehavior$group.Reward;
Group_trialNum    = allParticipantBehavior$group.trialNum;

lengthgroup= as.integer(allParticipantBehavior$group.SubjectNum[1,1]);
NumObservation=length(Group_Choice);

#run stan models: 
RA_data=list("NumObservation" = NumObservation, "NumSubject" = lengthgroup, 
             "Group_Choice"=Group_Choice, "Group_Reward"=Group_Reward, "Group_trialNum"=Group_trialNum);

fname = paste("RL_chain",chainNum,".rdata",sep="");

#Model definition
RA_fit=stan(file = file.path(model_dir, "RL.stan"), data=RA_data, verbose=FALSE, warmup=2000, iter=5000, chains=1, init="random", control=list(adapt_delta=0.99, stepsize=0.01, max_treedepth=15))


save(RA_fit, file = file.path(model_dir, fname))
print(lapply(get_sampler_params(RA_fit, inc_warmup = FALSE), summary, digits = 2))


