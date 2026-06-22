%% Figure 1

%% Figure 1C
% 7. prediction choice
% 9. self choice

clear; close all

addpath('../behavior_data/OL');
load('OL_Indiv_data.mat');

COL_PARTNER = 4;
COL_PREDICTION = 7;
COL_SELF = 9;

n_subj = numel(rev_total_data_indiv);
prediction_rate = nan(n_subj, 1);
partner_rate = nan(n_subj, 1);
self_rate = nan(n_subj, 1);

for subj = total_subj
    prediction_rate(subj, 1) = mean(rev_total_data_indiv{subj}(:, COL_PREDICTION));
    partner_rate(subj, 1) = mean(rev_total_data_indiv{subj}(:, COL_PARTNER));
    self_rate(subj, 1) = mean(rev_total_data_indiv{subj}(:, COL_SELF));
end

data = [prediction_rate, partner_rate, self_rate];
means = nanmean(data);
sems = nanstd(data) ./ sqrt(sum(~isnan(data), 1));

colors = [0.7 0.7 0.7; 50/255 150/255 50/255; 0.3 0.3 0.3];
x = 1:length(means);
jitter_amount = 0.25;

figure('color', 'w', 'Position', [500, 500, 320, 280]);
for i = 1:length(means)
    bar(x(i), means(i), 'FaceColor', colors(i, :), 'LineWidth', 2, 'FaceAlpha', 0.8);
    hold on;
    jitter_values = -jitter_amount + (2*jitter_amount).*rand(size(data(:,i)));
    scatter(x(i) + jitter_values, data(:,i), 'MarkerEdgeColor', 'k', 'MarkerFaceColor', colors(i, :));
end
errorbar(1:3, means, sems, 'k', 'linestyle', 'none', 'LineWidth', 2);
yline(0.5, '--', 'Color', 'k', 'LineWidth', 2);

set(gca, 'XTick', 1:3, 'XTickLabel', {'', '', ''}, 'FontSize', 18, 'LineWidth', 2);
ylabel('','FontSize', 12);
ylim([0 1]);

[h_pred_chance, p_pred_chance, ci_pred_chance, stats_pred_chance] = ttest(prediction_rate, 0.5);
[h_partner_chance, p_partner_chance, ci_partner_chance, stats_partner_chance] = ttest(partner_rate, 0.5);
[h_self_chance, p_self_chance, ci_self_chance, stats_self_chance] = ttest(self_rate, 0.5);

[h_self_partner, p_self_partner, ci_self_partner, stats_self_partner] = ttest(self_rate, partner_rate);
[h_pred_self, p_pred_self, ci_pred_self, stats_pred_self] = ttest(prediction_rate, self_rate);
%% Figure 1D

if ~exist('data_indiv_8', 'var') || ~exist('COL_SELF', 'var')
    addpath('../behavior_data/OL');
    load('OL_Indiv_data.mat');
    COL_SELF = 9;
end

n_trials = size(data_indiv_8{total_subj(1)}, 1);
n_subj = numel(data_indiv_8);
self_choice_8 = nan(n_trials, n_subj);
self_choice_10 = nan(n_trials, n_subj);
self_choice_12 = nan(n_trials, n_subj);
for subj = total_subj
    self_choice_8(:, subj) = data_indiv_8{subj}(:, COL_SELF);
    self_choice_10(:, subj) = data_indiv_10{subj}(:, COL_SELF);
    self_choice_12(:, subj) = data_indiv_12{subj}(:, COL_SELF);
end
mean_self_choice_8 = nanmean(self_choice_8, 2);
mean_self_choice_10 = nanmean(self_choice_10, 2);
mean_self_choice_12 = nanmean(self_choice_12, 2);

sem_self_choice_8 = nanstd(self_choice_8, 0, 2) / sqrt(sum(~isnan(self_choice_8), 2));
sem_self_choice_10 = nanstd(self_choice_10, 0, 2) / sqrt(sum(~isnan(self_choice_10), 2));
sem_self_choice_12 = nanstd(self_choice_12, 0, 2) / sqrt(sum(~isnan(self_choice_12), 2));

windowSize = 3;  % Size of the window for averaging
datasets = {mean_self_choice_8, mean_self_choice_10, mean_self_choice_12};
sem_datasets = {sem_self_choice_8, sem_self_choice_10, sem_self_choice_12};
colors = [135 206 250; 70 130 180; 0 50 150] / 255;
probThresholds = [8, 10, 12]; % Thresholds for changing probability

for dataIndex = 1:length(datasets)
    data = datasets{dataIndex};
    sem_data = sem_datasets{dataIndex};
    numTrials = length(data);
    movingAvg = zeros(numTrials-2, 1);
    movingSEM = zeros(numTrials-2, 1);
    for i = 2:numTrials-1
        movingAvg(i-1) = mean(data(i-1:i+1));
        movingSEM(i-1) = mean(sem_data(i-1:i+1));
    end

    prob = zeros(numTrials, 1);
    prob(1:probThresholds(dataIndex)) = 0.7; 
    prob(probThresholds(dataIndex)+1:end) = 0.3;
    figure('color', 'w', 'Position', [500, 500, 280, 200]);
    hold on;
    upper_bound = movingAvg + movingSEM;
    lower_bound = movingAvg - movingSEM;
    fill([2:numTrials-1 fliplr(2:numTrials-1)], [upper_bound' fliplr(lower_bound')], colors(dataIndex,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    plot(2:numTrials-1, movingAvg, 'Color', colors(dataIndex, :), 'LineWidth', 3);
    plot(2:numTrials-1, prob(2:end-1), 'Color', [0.8 0.8 0.8], 'LineWidth', 2, 'LineStyle', '--');
    xlim([1 20]);
    ylim([0 1]);
    xticks([1 5 10 15 20]);
    yticks([0 0.2 0.4 0.6 0.8 1]);
    set(gca, 'FontSize', 18, 'FontName', 'Arial', 'LineWidth', 2);
    legend({'','Self','Actual'}, 'Location', 'northeast', 'FontSize', 14);
end
