data { //#input data, anything in this block needs to be in the stanfit object
  int<lower=1> NumObservation;
  int<lower=1> NumSubject;
  
  int Group_Choice[NumObservation,1];
  int Group_Reward[NumObservation,1];
  int Group_trialNum[NumSubject,1];
}

parameters { //#anything with a prior goes here
  vector[1] mu_p; 		      //mean of parameters
  vector<lower=0>[1] s_p; 	//variance of parameters
  real<lower=0, upper=1> lr[NumSubject];
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

      if (Group_Choice[trialIndex,1]==1){
        Q_high[trialIndex+1] = Q_high[trialIndex] + lr[subjIndex] * (Group_Reward[trialIndex,1] - Q_high[trialIndex]);
        Q_low[trialIndex+1] = Q_low[trialIndex];
      }
      
      if (Group_Choice[trialIndex,1]==0){
        Q_high[trialIndex+1] = Q_high[trialIndex];
        Q_low[trialIndex+1] = Q_low[trialIndex] + lr[subjIndex] * (Group_Reward[trialIndex,1] - Q_low[trialIndex]);
      }
      
      Group_Choice[trialIndex,1] ~ bernoulli_logit_lpmf(invTemp[subjIndex] * (Q_high[trialIndex] - Q_low[trialIndex])); //#functions as softmax
      
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
        
      if (Group_Choice[trialIndex,1]==1){
        Q_high[trialIndex+1] = Q_high[trialIndex] + lr[subjIndex] * (Group_Reward[trialIndex,1] - Q_high[trialIndex]);
        Q_low[trialIndex+1] = Q_low[trialIndex];
      } else if (Group_Choice[trialIndex,1]==0){
        Q_high[trialIndex+1] = Q_high[trialIndex];
        Q_low[trialIndex+1] = Q_low[trialIndex] + lr[subjIndex] * (Group_Reward[trialIndex,1] - Q_low[trialIndex]);
      }
        
        log_lik[subjIndex] = log_lik[subjIndex] + bernoulli_logit_lpmf(Group_Choice[trialIndex,1] | invTemp[subjIndex] * (Q_high[trialIndex] - Q_low[trialIndex]));
      }
      initIndex = initIndex+Group_trialNum[subjIndex,1];
    }
  }
}