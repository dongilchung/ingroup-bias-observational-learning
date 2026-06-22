data { //#input data, anything in this block needs to be in the stanfit object
  int<lower=1> NumObservation;
  int<lower=1> NumSubject;
  
  int Group_choice[NumObservation,1];
  int Group_partnerChoice[NumObservation,1];
  int Group_partnerReward[NumObservation,1];
  int Group_partnerIdentity[NumObservation,1];
  int Group_trialNum[NumSubject,1];
  int Group_predCond[NumObservation,1];
  int Group_prevCond[NumObservation,1];
}

parameters { //#anything with a prior goes here
  vector[1] mu_p; 		      //mean of parameters
  vector<lower=0>[1] s_p; 	//variance of parameters
  real<lower=0, upper=1> lrIn[NumSubject];
  real<lower=0, upper=1> lrOut[NumSubject];
  vector[NumSubject] invTemp_raw;
}

transformed parameters { //#transformations on parameters (as name suggests)

real<lower=0> invTemp[NumSubject];
  
  for (subjIndex in 1:NumSubject) {
    invTemp[subjIndex] = 10*Phi_approx(mu_p[1] + s_p[1] * invTemp_raw[subjIndex]); 
  }
}

model {
  int initIndex;
  vector[NumObservation+1] Q_high;
  vector[NumObservation+1] Q_low;
  vector[NumObservation] P_high;
  vector[NumObservation] P_low;
  int initTrial;
  
  //# hyperparameters
  mu_p ~ normal(0,10);						//top level priors- v.wide
  s_p  ~ cauchy(0,2.5);
  
  invTemp_raw  ~ normal(0,1.0);

  initIndex = 1;
  for (subjIndex in 1:NumSubject) {
    for (trialIndex in initIndex:(initIndex+Group_trialNum[subjIndex,1]-1)) {
      
      if (trialIndex%20==1){
        initTrial=0;
      }
      
      initTrial=initTrial+1;
      
      if (initTrial==1) {
        Q_high[trialIndex]=0.5;
        Q_low[trialIndex]=0.5;
      }
      
      P_high[trialIndex] = inv_logit(invTemp[subjIndex] * (Q_high[trialIndex] - Q_low[trialIndex]));
      P_low[trialIndex] = 1 - P_high[trialIndex];
      
      if (Group_partnerIdentity[trialIndex,1]==1){
        if (Group_partnerChoice[trialIndex,1]==1){
          Q_high[trialIndex+1] = Q_high[trialIndex] + lrIn[subjIndex] * (Group_partnerReward[trialIndex,1] - Q_high[trialIndex]);
          Q_low[trialIndex+1] = Q_low[trialIndex];
        } else if (Group_partnerChoice[trialIndex,1]==0){
          Q_high[trialIndex+1] = Q_high[trialIndex];
          Q_low[trialIndex+1] = Q_low[trialIndex] + lrIn[subjIndex] * (Group_partnerReward[trialIndex,1] - Q_low[trialIndex]);
        }
      } else if (Group_partnerIdentity[trialIndex,1]==2){
        if (Group_partnerChoice[trialIndex,1]==1){
          Q_high[trialIndex+1] = Q_high[trialIndex] + lrOut[subjIndex] * (Group_partnerReward[trialIndex,1] - Q_high[trialIndex]);
          Q_low[trialIndex+1] = Q_low[trialIndex];
        } else if (Group_partnerChoice[trialIndex,1]==0){
          Q_high[trialIndex+1] = Q_high[trialIndex];
          Q_low[trialIndex+1] = Q_low[trialIndex] + lrOut[subjIndex] * (Group_partnerReward[trialIndex,1] - Q_low[trialIndex]);
        }
      }
      
      target += bernoulli_logit_lpmf(Group_choice[trialIndex,1] | invTemp[subjIndex] * (Q_high[trialIndex+1] - Q_low[trialIndex+1])); //#functions as softmax
      
    }
    initIndex = initIndex+Group_trialNum[subjIndex,1];
  }
}

generated quantities {
  real log_lik[NumSubject];
  int initIndex;
  int initTrial;
  vector[NumObservation+1] Q_high;
  vector[NumObservation+1] Q_low;
  vector[NumObservation] P_high;
  vector[NumObservation] P_low;
  { //#local section, this saves time and space
    initIndex = 1;
    for (subjIndex in 1:NumSubject) {
      log_lik[subjIndex] = 0;
      
      initTrial = 0;
      for (trialIndex in initIndex:(initIndex+Group_trialNum[subjIndex,1]-1)) {
        
        if(trialIndex%20==1){
          initTrial=0;
        }
        
        initTrial=initTrial+1;
      
        if (initTrial==1) {
          Q_high[trialIndex]=0.5;
          Q_low[trialIndex]=0.5;
        }
        
        P_high[trialIndex] = inv_logit(invTemp[subjIndex] * (Q_high[trialIndex] - Q_low[trialIndex]));
        P_low[trialIndex] = 1 - P_high[trialIndex];
        
        if (Group_partnerIdentity[trialIndex,1]==1){
          if (Group_partnerChoice[trialIndex,1]==1){
            Q_high[trialIndex+1] = Q_high[trialIndex] + lrIn[subjIndex] * (Group_partnerReward[trialIndex,1] - Q_high[trialIndex]);
            Q_low[trialIndex+1] = Q_low[trialIndex];
          } else if (Group_partnerChoice[trialIndex,1]==0){
            Q_high[trialIndex+1] = Q_high[trialIndex];
            Q_low[trialIndex+1] = Q_low[trialIndex] + lrIn[subjIndex] * (Group_partnerReward[trialIndex,1] - Q_low[trialIndex]);
          }
        } else if (Group_partnerIdentity[trialIndex,1]==2){
          if (Group_partnerChoice[trialIndex,1]==1){
            Q_high[trialIndex+1] = Q_high[trialIndex] + lrOut[subjIndex] * (Group_partnerReward[trialIndex,1] - Q_high[trialIndex]);
            Q_low[trialIndex+1] = Q_low[trialIndex];
          } else if (Group_partnerChoice[trialIndex,1]==0){
            Q_high[trialIndex+1] = Q_high[trialIndex];
            Q_low[trialIndex+1] = Q_low[trialIndex] + lrOut[subjIndex] * (Group_partnerReward[trialIndex,1] - Q_low[trialIndex]);
          }
        }
        
        log_lik[subjIndex] = log_lik[subjIndex] + bernoulli_logit_lpmf(Group_choice[trialIndex,1] | invTemp[subjIndex] * (Q_high[trialIndex+1] - Q_low[trialIndex+1]));
        
      }
      initIndex = initIndex+Group_trialNum[subjIndex,1];
    }
  }
}
