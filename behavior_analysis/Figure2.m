%% Figure 2

%% Figure 2B - Predicted result

clear; close all

COLOR_PRED_SUCCESS = [0.4660 0.6740 0.1880];
COLOR_PRED_FAIL = [0.5 0.5 0.5];

% Unbiased
unbiased_data = [0.8 0.8; 0.7 0.7];
figure('color', 'w', 'Position', [500, 500, 240, 240]);
b = bar(unbiased_data, 'grouped', 'LineWidth', 2);
hold on;
b(1).FaceColor = COLOR_PRED_SUCCESS;
b(2).FaceColor = COLOR_PRED_FAIL;

ylim([0.5 1]);
legend({'Prediction Success', 'Prediction Fail'}, 'FontSize', 12);
xticks(1:3);
xticklabels({'', '', ''});
yticks([]);
set(gca, 'FontSize', 20, 'LineWidth', 2);
hold off;

% Prediction bias
predbias_data = [0.9 0.7; 0.6 0.8];
figure('color', 'w', 'Position', [500, 500, 240, 240]);
b = bar(predbias_data, 'grouped', 'LineWidth', 2);
hold on;
b(1).FaceColor = COLOR_PRED_SUCCESS;
b(2).FaceColor = COLOR_PRED_FAIL;

ylim([0.5 1]);
xticks(1:3);
xticklabels({'', '', ''});
yticks([]);
set(gca, 'FontSize', 20, 'LineWidth', 2);
hold off;
%% Figure 2B - Actual result

% 4. partner choice
% 5. partner reward
% 7. prediction choice
% 9. self choice

addpath('../behavior_data/OL');
load('OL_Indiv_data.mat');

COL_GROUP = 3;
COL_PARTNER = 4;
COL_REWARD = 5;
COL_PREDICTION = 7;
COL_SELF = 9;

data_blocks = {data_indiv_8, data_indiv_10, data_indiv_12};
n_subj = numel(data_indiv_8);
n_blocks = numel(data_blocks);
n_trials = size(data_blocks{1}{total_subj(1)}, 1);

total_pred_win_count = zeros(n_subj, 1);
total_pred_lose_count = zeros(n_subj, 1);
total_pred_win_stay_count = zeros(n_subj, 1);
total_pred_lose_shift_count = zeros(n_subj, 1);
total_nopred_win_count = zeros(n_subj, 1);
total_nopred_lose_count = zeros(n_subj, 1);
total_nopred_win_stay_count = zeros(n_subj, 1);
total_nopred_lose_shift_count = zeros(n_subj, 1);
pred_win_stay_behavior = nan(n_subj, n_blocks);
pred_lose_shift_behavior = nan(n_subj, n_blocks);
nopred_win_stay_behavior = nan(n_subj, n_blocks);
nopred_lose_shift_behavior = nan(n_subj, n_blocks);

for subj = total_subj
    for p = 1:n_blocks
        data = data_blocks{p}{subj};
        
        pred_win_count = 0; pred_win_stay_count = 0; pred_win_shift_count = 0;
        pred_lose_count = 0; pred_lose_stay_count = 0; pred_lose_shift_count = 0;
        nopred_win_count = 0; nopred_win_stay_count = 0; nopred_win_shift_count = 0;
        nopred_lose_count = 0; nopred_lose_stay_count = 0; nopred_lose_shift_count = 0;
        
        for t = 1:n_trials
            if data(t, COL_PREDICTION) == data(t, COL_PARTNER)
                if data(t, COL_REWARD) == 1
                    pred_win_count = pred_win_count + 1;
                    if data(t, COL_SELF) == data(t, COL_PARTNER)
                        pred_win_stay_count = pred_win_stay_count + 1;
                    elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                        pred_win_shift_count = pred_win_shift_count + 1;
                    end
                else
                    pred_lose_count = pred_lose_count + 1;
                    if data(t, COL_SELF) == data(t, COL_PARTNER)
                        pred_lose_stay_count = pred_lose_stay_count + 1;
                    elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                        pred_lose_shift_count = pred_lose_shift_count + 1;
                    end
                end
            else
                if data(t, COL_REWARD) == 1
                    nopred_win_count = nopred_win_count + 1;
                    if data(t, COL_SELF) == data(t, COL_PARTNER)
                        nopred_win_stay_count = nopred_win_stay_count + 1;
                    elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                        nopred_win_shift_count = nopred_win_shift_count + 1;
                    end
                else
                    nopred_lose_count = nopred_lose_count + 1;
                    if data(t, COL_SELF) == data(t, COL_PARTNER)
                        nopred_lose_stay_count = nopred_lose_stay_count + 1;
                    elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                        nopred_lose_shift_count = nopred_lose_shift_count + 1;
                    end
                end
            end
        end
        pred_win_stay_behavior(subj,p) = pred_win_stay_count/pred_win_count;
        pred_lose_shift_behavior(subj,p) = pred_lose_shift_count/pred_lose_count;
        nopred_win_stay_behavior(subj,p) = nopred_win_stay_count/nopred_win_count;
        nopred_lose_shift_behavior(subj,p) = nopred_lose_shift_count/nopred_lose_count;

        total_pred_win_count(subj,1) = total_pred_win_count(subj,1) + pred_win_count;
        total_pred_lose_count(subj,1) = total_pred_lose_count(subj,1) + pred_lose_count;
        total_nopred_win_count(subj,1) = total_nopred_win_count(subj,1) + nopred_win_count;
        total_nopred_lose_count(subj,1) = total_nopred_lose_count(subj,1) + nopred_lose_count;

        total_pred_win_stay_count(subj,1) = total_pred_win_stay_count(subj,1) + pred_win_stay_count;
        total_pred_lose_shift_count(subj,1) = total_pred_lose_shift_count(subj,1) + pred_lose_shift_count;
        total_nopred_win_stay_count(subj,1) = total_nopred_win_stay_count(subj,1) + nopred_win_stay_count;
        total_nopred_lose_shift_count(subj,1) = total_nopred_lose_shift_count(subj,1) + nopred_lose_shift_count;
    end
end

pred_WS = total_pred_win_stay_count ./ total_pred_win_count;
pred_LS = total_pred_lose_shift_count ./ total_pred_lose_count;
pred_WSLS = (total_pred_win_stay_count + total_pred_lose_shift_count) ./ (total_pred_win_count + total_pred_lose_count);

nopred_WS = total_nopred_win_stay_count ./ total_nopred_win_count;
nopred_LS = total_nopred_lose_shift_count ./ total_nopred_lose_count;
nopred_WSLS = (total_nopred_win_stay_count + total_nopred_lose_shift_count) ./ (total_nopred_win_count + total_nopred_lose_count);

mean_pred_WS = mean(pred_WS(total_subj,:));
mean_pred_LS = mean(pred_LS(total_subj,:));
mean_pred_WSLS = mean(pred_WSLS(total_subj,:));

mean_nopred_WS = mean(nopred_WS(total_subj,:));
mean_nopred_LS = mean(nopred_LS(total_subj,:));
mean_nopred_WSLS = mean(nopred_WSLS(total_subj,:));

sem_pred_WS = std(pred_WS(total_subj,:))/sqrt(length(total_subj));
sem_pred_LS = std(pred_LS(total_subj,:))/sqrt(length(total_subj));
sem_pred_WSLS = std(pred_WSLS(total_subj,:))/sqrt(length(total_subj));

sem_nopred_WS = std(nopred_WS(total_subj,:))/sqrt(length(total_subj));
sem_nopred_LS = std(nopred_LS(total_subj,:))/sqrt(length(total_subj));
sem_nopred_WSLS = std(nopred_WSLS(total_subj,:))/sqrt(length(total_subj));

pred_data = [mean_pred_WS mean_nopred_WS; ...
    mean_pred_LS mean_nopred_LS];
pred_sem_data = [sem_pred_WS sem_nopred_WS; ...
    sem_pred_LS sem_nopred_LS];

numGroups = size(pred_data, 1);
numBars = size(pred_data, 2); 

groupWidth = min(0.8, numBars/(numBars + 1.5));

figure('color', 'w', 'Position', [500, 500, 320, 280]);
b = bar(pred_data, 'grouped', 'LineWidth', 2);
hold on;
b(1).FaceColor = COLOR_PRED_SUCCESS;
b(2).FaceColor = COLOR_PRED_FAIL;

for i = 1:numBars
    x = (1:numGroups) - groupWidth/2 + (2*i-1) * groupWidth / (2*numBars); 
    err = errorbar(x, pred_data(:,i), pred_sem_data(:,i), 'k', 'linestyle', 'none', 'LineWidth', 3);
    err.CapSize = 15;
end
ylim([0.5 1]);
legend({'Prediction Success', 'Prediction Fail'}, 'FontSize', 12);
xticks(1:3);
xticklabels({'', '', ''});
set(gca, 'FontSize', 20, 'LineWidth', 2);

hold off;

[h_ws_pred_vs_nopred, p_ws_pred_vs_nopred, ci_ws_pred_vs_nopred, stats_ws_pred_vs_nopred] = ttest(pred_WS(total_subj), nopred_WS(total_subj));
[h_ls_pred_vs_nopred, p_ls_pred_vs_nopred, ci_ls_pred_vs_nopred, stats_ls_pred_vs_nopred] = ttest(pred_LS(total_subj), nopred_LS(total_subj));

%%% (Prediction) Win-Stay & Lose-Shift
%% Figure 2C

% 4. partner choice
% 5. partner reward
% 7. prediction choice
% 9. self choice

if ~exist('data_blocks', 'var') || ~exist('COL_GROUP', 'var')
    addpath('../behavior_data/OL');
    load('OL_Indiv_data.mat');
    COL_GROUP = 3;
    COL_PARTNER = 4;
    COL_REWARD = 5;
    COL_PREDICTION = 7;
    COL_SELF = 9;
    data_blocks = {data_indiv_8, data_indiv_10, data_indiv_12};
    n_subj = numel(data_indiv_8);
    n_blocks = numel(data_blocks);
    n_trials = size(data_blocks{1}{total_subj(1)}, 1);
end

total_pred_win_In_count = zeros(n_subj, 1);
total_pred_lose_In_count = zeros(n_subj, 1);
total_pred_win_In_stay_count = zeros(n_subj, 1);
total_pred_lose_In_shift_count = zeros(n_subj, 1);
total_nopred_win_In_count = zeros(n_subj, 1);
total_nopred_lose_In_count = zeros(n_subj, 1);
total_nopred_win_In_stay_count = zeros(n_subj, 1);
total_nopred_lose_In_shift_count = zeros(n_subj, 1);

total_pred_win_Out_count = zeros(n_subj, 1);
total_pred_lose_Out_count = zeros(n_subj, 1);
total_pred_win_Out_stay_count = zeros(n_subj, 1);
total_pred_lose_Out_shift_count = zeros(n_subj, 1);
total_nopred_win_Out_count = zeros(n_subj, 1);
total_nopred_lose_Out_count = zeros(n_subj, 1);
total_nopred_win_Out_stay_count = zeros(n_subj, 1);
total_nopred_lose_Out_shift_count = zeros(n_subj, 1);

pred_win_In_stay_behavior = nan(n_subj, n_blocks);
pred_lose_In_shift_behavior = nan(n_subj, n_blocks);
nopred_win_In_stay_behavior = nan(n_subj, n_blocks);
nopred_lose_In_shift_behavior = nan(n_subj, n_blocks);
pred_win_Out_stay_behavior = nan(n_subj, n_blocks);
pred_lose_Out_shift_behavior = nan(n_subj, n_blocks);
nopred_win_Out_stay_behavior = nan(n_subj, n_blocks);
nopred_lose_Out_shift_behavior = nan(n_subj, n_blocks);

for subj = total_subj
    for p = 1:n_blocks
        data = data_blocks{p}{subj};
        
        pred_win_In_count = 0; pred_win_In_stay_count = 0; pred_win_In_shift_count = 0;
        pred_lose_In_count = 0; pred_lose_In_stay_count = 0; pred_lose_In_shift_count = 0;
        nopred_win_In_count = 0; nopred_win_In_stay_count = 0; nopred_win_In_shift_count = 0;
        nopred_lose_In_count = 0; nopred_lose_In_stay_count = 0; nopred_lose_In_shift_count = 0;
        
        pred_win_Out_count = 0; pred_win_Out_stay_count = 0; pred_win_Out_shift_count = 0;
        pred_lose_Out_count = 0; pred_lose_Out_stay_count = 0; pred_lose_Out_shift_count = 0;
        nopred_win_Out_count = 0; nopred_win_Out_stay_count = 0; nopred_win_Out_shift_count = 0;
        nopred_lose_Out_count = 0; nopred_lose_Out_stay_count = 0; nopred_lose_Out_shift_count = 0;
        
        for t = 1:n_trials
            if data(t, COL_GROUP) == 1
                if data(t, COL_PREDICTION) == data(t, COL_PARTNER)
                    if data(t, COL_REWARD) == 1
                        pred_win_In_count = pred_win_In_count + 1;
                        if data(t, COL_SELF) == data(t, COL_PARTNER)
                            pred_win_In_stay_count = pred_win_In_stay_count + 1;
                        elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                            pred_win_In_shift_count = pred_win_In_shift_count + 1;
                        end
                    else
                        pred_lose_In_count = pred_lose_In_count + 1;
                        if data(t, COL_SELF) == data(t, COL_PARTNER)
                            pred_lose_In_stay_count = pred_lose_In_stay_count + 1;
                        elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                            pred_lose_In_shift_count = pred_lose_In_shift_count + 1;
                        end
                    end
                else
                    if data(t, COL_REWARD) == 1
                        nopred_win_In_count = nopred_win_In_count + 1;
                        if data(t, COL_SELF) == data(t, COL_PARTNER)
                            nopred_win_In_stay_count = nopred_win_In_stay_count + 1;
                        elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                            nopred_win_In_shift_count = nopred_win_In_shift_count + 1;
                        end
                    else
                        nopred_lose_In_count = nopred_lose_In_count + 1;
                        if data(t, COL_SELF) == data(t, COL_PARTNER)
                            nopred_lose_In_stay_count = nopred_lose_In_stay_count + 1;
                        elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                            nopred_lose_In_shift_count = nopred_lose_In_shift_count + 1;
                        end
                    end
                end
            else
                if data(t, COL_PREDICTION) == data(t, COL_PARTNER)
                    if data(t, COL_REWARD) == 1
                        pred_win_Out_count = pred_win_Out_count + 1;
                        if data(t, COL_SELF) == data(t, COL_PARTNER)
                            pred_win_Out_stay_count = pred_win_Out_stay_count + 1;
                        elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                            pred_win_Out_shift_count = pred_win_Out_shift_count + 1;
                        end
                    else
                        pred_lose_Out_count = pred_lose_Out_count + 1;
                        if data(t, COL_SELF) == data(t, COL_PARTNER)
                            pred_lose_Out_stay_count = pred_lose_Out_stay_count + 1;
                        elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                            pred_lose_Out_shift_count = pred_lose_Out_shift_count + 1;
                        end
                    end
                else
                    if data(t, COL_REWARD) == 1
                        nopred_win_Out_count = nopred_win_Out_count + 1;
                        if data(t, COL_SELF) == data(t, COL_PARTNER)
                            nopred_win_Out_stay_count = nopred_win_Out_stay_count + 1;
                        elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                            nopred_win_Out_shift_count = nopred_win_Out_shift_count + 1;
                        end
                    else
                        nopred_lose_Out_count = nopred_lose_Out_count + 1;
                        if data(t, COL_SELF) == data(t, COL_PARTNER)
                            nopred_lose_Out_stay_count = nopred_lose_Out_stay_count + 1;
                        elseif data(t, COL_SELF) ~= data(t, COL_PARTNER)
                            nopred_lose_Out_shift_count = nopred_lose_Out_shift_count + 1;
                        end
                    end
                end
            end
        end
        pred_win_In_stay_behavior(subj,p) = pred_win_In_stay_count/pred_win_In_count;
        pred_lose_In_shift_behavior(subj,p) = pred_lose_In_shift_count/pred_lose_In_count;
        nopred_win_In_stay_behavior(subj,p) = nopred_win_In_stay_count/nopred_win_In_count;
        nopred_lose_In_shift_behavior(subj,p) = nopred_lose_In_shift_count/nopred_lose_In_count;

        pred_win_Out_stay_behavior(subj,p) = pred_win_Out_stay_count/pred_win_Out_count;
        pred_lose_Out_shift_behavior(subj,p) = pred_lose_Out_shift_count/pred_lose_Out_count;
        nopred_win_Out_stay_behavior(subj,p) = nopred_win_Out_stay_count/nopred_win_Out_count;
        nopred_lose_Out_shift_behavior(subj,p) = nopred_lose_Out_shift_count/nopred_lose_Out_count;

        total_pred_win_In_count(subj,1) = total_pred_win_In_count(subj,1) + pred_win_In_count;
        total_pred_lose_In_count(subj,1) = total_pred_lose_In_count(subj,1) + pred_lose_In_count;
        total_nopred_win_In_count(subj,1) = total_nopred_win_In_count(subj,1) + nopred_win_In_count;
        total_nopred_lose_In_count(subj,1) = total_nopred_lose_In_count(subj,1) + nopred_lose_In_count;
        
        total_pred_win_Out_count(subj,1) = total_pred_win_Out_count(subj,1) + pred_win_Out_count;
        total_pred_lose_Out_count(subj,1) = total_pred_lose_Out_count(subj,1) + pred_lose_Out_count;
        total_nopred_win_Out_count(subj,1) = total_nopred_win_Out_count(subj,1) + nopred_win_Out_count;
        total_nopred_lose_Out_count(subj,1) = total_nopred_lose_Out_count(subj,1) + nopred_lose_Out_count;

        total_pred_win_In_stay_count(subj,1) = total_pred_win_In_stay_count(subj,1) + pred_win_In_stay_count;
        total_pred_lose_In_shift_count(subj,1) = total_pred_lose_In_shift_count(subj,1) + pred_lose_In_shift_count;
        total_nopred_win_In_stay_count(subj,1) = total_nopred_win_In_stay_count(subj,1) + nopred_win_In_stay_count;
        total_nopred_lose_In_shift_count(subj,1) = total_nopred_lose_In_shift_count(subj,1) + nopred_lose_In_shift_count;

        total_pred_win_Out_stay_count(subj,1) = total_pred_win_Out_stay_count(subj,1) + pred_win_Out_stay_count;
        total_pred_lose_Out_shift_count(subj,1) = total_pred_lose_Out_shift_count(subj,1) + pred_lose_Out_shift_count;
        total_nopred_win_Out_stay_count(subj,1) = total_nopred_win_Out_stay_count(subj,1) + nopred_win_Out_stay_count;
        total_nopred_lose_Out_shift_count(subj,1) = total_nopred_lose_Out_shift_count(subj,1) + nopred_lose_Out_shift_count;
    end
end

% In
pred_WS_In = total_pred_win_In_stay_count ./ total_pred_win_In_count;
pred_LS_In = total_pred_lose_In_shift_count ./ total_pred_lose_In_count;
pred_WSLS_In = (total_pred_win_In_stay_count + total_pred_lose_In_shift_count) ./ (total_pred_win_In_count + total_pred_lose_In_count);

nopred_WS_In = total_nopred_win_In_stay_count ./ total_nopred_win_In_count;
nopred_LS_In = total_nopred_lose_In_shift_count ./ total_nopred_lose_In_count;
nopred_WSLS_In = (total_nopred_win_In_stay_count + total_nopred_lose_In_shift_count) ./ (total_nopred_win_In_count + total_nopred_lose_In_count);

mean_pred_WS_In = mean(pred_WS_In(total_subj,:), 'omitnan');
sem_pred_WS_In = std(pred_WS_In(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));
mean_pred_LS_In = mean(pred_LS_In(total_subj,:), 'omitnan');
sem_pred_LS_In = std(pred_LS_In(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));
mean_pred_WSLS_In = mean(pred_WSLS_In(total_subj,:), 'omitnan');
sem_pred_WSLS_In = std(pred_WSLS_In(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));

mean_nopred_WS_In = mean(nopred_WS_In(total_subj,:), 'omitnan');
sem_nopred_WS_In = std(nopred_WS_In(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));
mean_nopred_LS_In = mean(nopred_LS_In(total_subj,:), 'omitnan');
sem_nopred_LS_In = std(nopred_LS_In(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));
mean_nopred_WSLS_In = mean(nopred_WSLS_In(total_subj,:), 'omitnan');
sem_nopred_WSLS_In = std(nopred_WSLS_In(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));
% Out
pred_WS_Out = total_pred_win_Out_stay_count ./ total_pred_win_Out_count;
pred_LS_Out = total_pred_lose_Out_shift_count ./ total_pred_lose_Out_count;
pred_WSLS_Out = (total_pred_win_Out_stay_count + total_pred_lose_Out_shift_count) ./ (total_pred_win_Out_count + total_pred_lose_Out_count);

nopred_WS_Out = total_nopred_win_Out_stay_count ./ total_nopred_win_Out_count;
nopred_LS_Out = total_nopred_lose_Out_shift_count ./ total_nopred_lose_Out_count;
nopred_WSLS_Out = (total_nopred_win_Out_stay_count + total_nopred_lose_Out_shift_count) ./ (total_nopred_win_Out_count + total_nopred_lose_Out_count);

mean_pred_WS_Out = mean(pred_WS_Out(total_subj,:), 'omitnan');
sem_pred_WS_Out = std(pred_WS_Out(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));
mean_pred_LS_Out = mean(pred_LS_Out(total_subj,:), 'omitnan');
sem_pred_LS_Out = std(pred_LS_Out(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));
mean_pred_WSLS_Out = mean(pred_WSLS_Out(total_subj,:), 'omitnan');
sem_pred_WSLS_Out = std(pred_WSLS_Out(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));

mean_nopred_WS_Out = mean(nopred_WS_Out(total_subj,:), 'omitnan');
sem_nopred_WS_Out = std(nopred_WS_Out(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));
mean_nopred_LS_Out = mean(nopred_LS_Out(total_subj,:), 'omitnan');
sem_nopred_LS_Out = std(nopred_LS_Out(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));
mean_nopred_WSLS_Out = mean(nopred_WSLS_Out(total_subj,:), 'omitnan');
sem_nopred_WSLS_Out = std(nopred_WSLS_Out(total_subj,:), 0, 'omitnan') ./ sqrt(length(total_subj));

% WS Group
data = [mean_pred_WS_In mean_nopred_WS_In; ...
    mean_pred_WS_Out mean_nopred_WS_Out];
sem_data = [sem_pred_WS_In sem_nopred_WS_In; ...
    sem_pred_WS_Out sem_nopred_WS_Out];

numGroups = size(data, 1);
numBars = size(data, 2); 

groupWidth = min(0.8, numBars/(numBars + 1.5));

figure('color', 'w', 'Position', [500, 500, 320, 280]);
b = bar(data, 'grouped', 'LineWidth', 2);
hold on;

b(1).FaceColor = COLOR_PRED_SUCCESS;
b(2).FaceColor = COLOR_PRED_FAIL;

for i = 1:numBars
    x = (1:numGroups) - groupWidth/2 + (2*i-1) * groupWidth / (2*numBars); 
    err = errorbar(x, data(:,i), sem_data(:,i), 'k', 'linestyle', 'none', 'LineWidth', 3);
    err.CapSize = 15;
end
ylim([0.5 1]);
xticks(1:3);
xticklabels({'', ''});
set(gca, 'FontSize', 20, 'LineWidth', 2);
hold off;

% LS Group
data = [mean_pred_LS_In mean_nopred_LS_In; ...
    mean_pred_LS_Out mean_nopred_LS_Out];
sem_data = [sem_pred_LS_In sem_nopred_LS_In; ...
    sem_pred_LS_Out sem_nopred_LS_Out];

numGroups = size(data, 1);
numBars = size(data, 2); 

groupWidth = min(0.8, numBars/(numBars + 1.5));

figure('color', 'w', 'Position', [500, 500, 320, 280]);
b = bar(data, 'grouped', 'LineWidth', 2);
hold on;
b(1).FaceColor = COLOR_PRED_SUCCESS;
b(2).FaceColor = COLOR_PRED_FAIL;

for i = 1:numBars
    x = (1:numGroups) - groupWidth/2 + (2*i-1) * groupWidth / (2*numBars); 
    err = errorbar(x, data(:,i), sem_data(:,i), 'k', 'linestyle', 'none', 'LineWidth', 3);
    err.CapSize = 15;
end

legend({'Prediction Success', 'Prediction Fail'}, 'FontSize', 12, 'Location', 'North');
xticks(1:3);
xticklabels({'', ''});
set(gca, 'FontSize', 20, 'LineWidth', 2);
ylim([0.5 1]);

hold off;
