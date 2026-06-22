% 1. trial # 
% 2. swap index
% 3. choice rt
% 4. self choice
% 5. self reward
% 6. point

%% each participants data

clear

script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end

data_dir = fullfile(script_dir, '..', '..', '..', 'behavior_data', 'SL');
addpath(data_dir);

load('solo_data.mat', 'data_solo')

exclude_subj = [1 14 50 57 67 71 73 74 82 90 109 112];
total_subj = setdiff(1:136,exclude_subj);

group_SubjectNum = length(total_subj);

group_Choice = [];
group_Reward = [];
group_trialNum = [];

for subj = total_subj

    data = data_solo{subj};
    
    group_Choice = [group_Choice; data(:,4)];
    group_Reward = [group_Reward; data(:,5)];
    group_trialNum = [group_trialNum; size(data,1)];
    
end

save(fullfile(script_dir, 'estimate_data.mat'), 'group_*')
