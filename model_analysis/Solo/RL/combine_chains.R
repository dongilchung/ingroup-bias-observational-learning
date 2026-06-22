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
library(shinystan)

script_args <- commandArgs(FALSE)
script_file <- sub("^--file=", "", grep("^--file=", script_args, value = TRUE)[1])
model_dir <- if (!is.na(script_file)) dirname(normalizePath(script_file)) else normalizePath(getwd())
setwd(model_dir)

models <- c("RL_chain")

for(model_index in 1:length(models) ){
  chain_list = list.files(model_dir, pattern = paste0("^", models[model_index], "[0-9]+\\.rdata$"), full.names = TRUE)
  print(chain_list)
  fname = paste(models[model_index],".rdata",sep="")
  print(fname)
  if (length(chain_list) != 4){
    print(paste(fname,"has ", length(chain_list),"chains",sep=" "))
    next
  }
  
  
  all_chains = vector('list',4)
  
  for (ii in 1:4) {
    load(chain_list[ii])
    if(ii == 1){
      f1 <- RA_fit
    } else if(ii==2){
      f2 <- RA_fit
    }else if(ii==3){
      f3 <- RA_fit
    } else if(ii==4){
      f4 <- RA_fit
    }
  }
  RA_combined = sflist2stanfit(list(f1, f2, f3, f4))
  save(RA_combined, file = file.path(model_dir, fname))
  
  
  #mean of parameters 
  parameterExtract<-extract(RA_combined,pars=c("lr", "invTemp","mu_p","s_p"))
  medianPosteriorLr <- apply(parameterExtract$lr,2,median)
  medianPosteriorInvTemp <- apply(parameterExtract$invTemp,2,median)
  
  mylog_lik <- extract_log_lik(RA_combined,parameter_name = "log_lik")
  medianPosteriorGroup_m <- apply(parameterExtract$mu_p,2,median)
  medianPosteriorGroup_s <- apply(parameterExtract$s_p,2,median)
  
  writeMat(file.path(model_dir, paste(models[model_index], ".mat", sep = "")),
           medianPosteriorLr=medianPosteriorLr, 
           medianPosteriorInvTemp=medianPosteriorInvTemp, 
           
           log_lik=mylog_lik,
           medianPosteriorGroup_m=medianPosteriorGroup_m,
           medianPosteriorGroup_s=medianPosteriorGroup_s)
  
}


# diagnosis
# print(RA_combined,digits=4)

printRhat<-summary(RA_combined)$summary[,"Rhat"]
print(printRhat[1:10])
printNeff<-summary(RA_combined)$summary[,"n_eff"]
print(printNeff[1:10])

sum(get_sampler_params(RA_combined, inc_warmup = FALSE)[[1]][,"divergent__"])
sum(get_sampler_params(RA_combined, inc_warmup = FALSE)[[2]][,"divergent__"])
sum(get_sampler_params(RA_combined, inc_warmup = FALSE)[[3]][,"divergent__"])
sum(get_sampler_params(RA_combined, inc_warmup = FALSE)[[4]][,"divergent__"])

png(file="Fig.trace.png", width=600, height=350,unit="px",bg="transparent")
traceplot(RA_combined,pars=c("mu_p","s_p"));
dev.off()

png(file="Fig.pairs.png", width=1000, height=1000,unit="px",bg="transparent")
pairs(RA_combined,pars=c("mu_p","s_p","lp__"))
dev.off()

png(file="Fig.dense.png", width=600, height=350,unit="px",bg="transparent")
stan_dens(RA_combined, pars=c('mu_p','s_p'), separate_chains = TRUE)
dev.off()
