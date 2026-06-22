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

## Chain number is supplied as a command-line argument, e.g. Rscript OL.R 1
args <- commandArgs(trailingOnly = TRUE);
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else {
  chainNum <- args[1];
}

allParticipantBehavior <- readMat(file.path(model_dir, "estimate_data.mat"));

Group_choice   = allParticipantBehavior$group.choice;
Group_partnerChoice  = allParticipantBehavior$group.partnerChoice;
Group_partnerReward    = allParticipantBehavior$group.partnerReward;
Group_partnerIdentity    = allParticipantBehavior$group.partnerIdentity;
Group_trialNum    = allParticipantBehavior$group.trialNum;

Group_prevReward = allParticipantBehavior$group.prevReward;
Group_predReward = allParticipantBehavior$group.predReward;

Group_prevCond = allParticipantBehavior$group.prevCond;
Group_predCond = allParticipantBehavior$group.predCond;

lengthgroup= as.integer(allParticipantBehavior$group.SubjectNum[1,1]);
NumObservation=length(Group_choice);

#run stan models: 
RA_data=list("NumObservation" = NumObservation, "NumSubject" = lengthgroup, 
             "Group_partnerChoice"=Group_partnerChoice, "Group_partnerReward"=Group_partnerReward, "Group_partnerIdentity"=Group_partnerIdentity, "Group_trialNum"=Group_trialNum,
             "Group_prevReward"=Group_prevReward, "Group_predReward"=Group_predReward, "Group_predCond"=Group_predCond, "Group_prevCond"=Group_prevCond, "Group_choice"=Group_choice);

fname = paste("OL_chain",chainNum,".rdata",sep="");

#Model definition
RA_fit=stan(file = file.path(model_dir, "OL.stan"), data=RA_data, verbose=FALSE, warmup=2000, iter=5000, chains=1, init="random", control=list(adapt_delta=0.99, stepsize=0.01, max_treedepth=15))


save(RA_fit, file = file.path(model_dir, fname))
print(lapply(get_sampler_params(RA_fit, inc_warmup = FALSE), summary, digits = 2))



