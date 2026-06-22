%% Figure S2
%% Solo learning task
%% Figure S2B left

clear
close all

addpath('../function');

solo_data = load('../behavior_data/SL/solo_data.mat', 'rev_data_solo', 'total_subj');
rev_data_solo = solo_data.rev_data_solo;
total_subj = solo_data.total_subj;

COL_SELF_CHOICE = 4;
n_all_subjects = numel(rev_data_solo);
n_trials = size(rev_data_solo{total_subj(1)}, 1);

self_choice_solo = NaN(n_trials, n_all_subjects);
for subj = total_subj
    self_choice_solo(:, subj) = rev_data_solo{subj}(:, COL_SELF_CHOICE);
end

self_choice_solo_rate = mean(self_choice_solo(:, total_subj));
sem_choice_solo_rate = std(self_choice_solo_rate, 0, 2) / sqrt(numel(total_subj));

figure('color', 'w', 'Position', [500, 500, 320, 280]);
b = bar(1, mean(self_choice_solo_rate), 'FaceColor', 'flat', 'LineWidth', 2);
b.CData(1,:) = [0.4660 0.6740 0.1880];
hold on;
err = errorbar(1, mean(self_choice_solo_rate), sem_choice_solo_rate, 'k', 'linestyle', 'none', 'LineWidth', 3);
err.CapSize = 30;

yline(0.5, '--k','LineWidth',2);

xticks(1);
xticklabels({''});
set(gca, 'FontSize', 20, 'LineWidth', 2);
ylim([0 1]);
hold off;

[h, p, ci, stats] = ttest(self_choice_solo_rate, 0.5);
stats_FigureS2B_left = struct();
stats_FigureS2B_left.h = h;
stats_FigureS2B_left.p = p;
stats_FigureS2B_left.ci = ci;
stats_FigureS2B_left.stats = stats;
stats_FigureS2B_left.mean = mean(self_choice_solo_rate);
stats_FigureS2B_left.sem = sem_choice_solo_rate;

%% Figure S2B right

if ~exist('self_choice_solo', 'var') || ~exist('total_subj', 'var')
    solo_data = load('../behavior_data/SL/solo_data.mat', 'rev_data_solo', 'total_subj');
    rev_data_solo = solo_data.rev_data_solo;
    total_subj = solo_data.total_subj;

    COL_SELF_CHOICE = 4;
    n_all_subjects = numel(rev_data_solo);
    n_trials = size(rev_data_solo{total_subj(1)}, 1);

    self_choice_solo = NaN(n_trials, n_all_subjects);
    for subj = total_subj
        self_choice_solo(:, subj) = rev_data_solo{subj}(:, COL_SELF_CHOICE);
    end
end

political_groups = load('../behavior_data/PoliticalGroups.mat', 'Centrism', 'Conservatism', 'Progressivism');

Pro_ID = political_groups.Progressivism(:,1)';
Cen_ID = political_groups.Centrism(:,1)';
Con_ID = political_groups.Conservatism(:,1)';

self_choice_solo_Pro = self_choice_solo(:, Pro_ID);
self_choice_solo_Cen = self_choice_solo(:, Cen_ID);
self_choice_solo_Con = self_choice_solo(:, Con_ID);

choice_rate_Pro = mean(self_choice_solo_Pro);
choice_rate_Cen = mean(self_choice_solo_Cen);
choice_rate_Con = mean(self_choice_solo_Con);

total_self_choice_Pro = mean(self_choice_solo_Pro, 'all');
total_self_choice_Cen = mean(self_choice_solo_Cen, 'all');
total_self_choice_Con = mean(self_choice_solo_Con, 'all');
sem_total_self_choice_Pro = std(choice_rate_Pro) / sqrt(numel(Pro_ID));
sem_total_self_choice_Cen = std(choice_rate_Cen) / sqrt(numel(Cen_ID));
sem_total_self_choice_Con = std(choice_rate_Con) / sqrt(numel(Con_ID));

data = [total_self_choice_Pro total_self_choice_Cen total_self_choice_Con];
sem_data = [sem_total_self_choice_Pro sem_total_self_choice_Cen sem_total_self_choice_Con];

colors = [0 0 1; 0.5 0.5 0.5; 1 0 0];

figure('color', 'w', 'Position', [500, 500, 320, 280]);
b = bar(1:3, data, 'FaceColor', 'flat', 'LineWidth', 2);
for k = 1:3
    b.CData(k,:) = colors(k,:);
end
hold on;
err = errorbar(1:3, data, sem_data, 'k', 'linestyle', 'none', 'LineWidth', 3);
err.CapSize = 20;

yline(0.5, '--k','LineWidth',2);

xticks(1:3);
xticklabels({'',  '', ''});
set(gca, 'FontSize', 20, 'LineWidth', 2);
ylim([0 1]);
hold off;

[h_pro_con, p_pro_con] = ttest2(choice_rate_Pro, choice_rate_Con);
[h_pro, p_pro] = ttest(choice_rate_Pro, 0.5);
[h_cen, p_cen] = ttest(choice_rate_Cen, 0.5);
[h_con, p_con] = ttest(choice_rate_Con, 0.5);

stats_FigureS2B_right = struct();
stats_FigureS2B_right.data = data;
stats_FigureS2B_right.sem = sem_data;
stats_FigureS2B_right.group_mean = [mean(choice_rate_Pro) mean(choice_rate_Cen) mean(choice_rate_Con)];
stats_FigureS2B_right.group_sem = sem_data;
stats_FigureS2B_right.pro_vs_con = struct('h', h_pro_con, 'p', p_pro_con);
stats_FigureS2B_right.pro_vs_chance = struct('h', h_pro, 'p', p_pro);
stats_FigureS2B_right.cen_vs_chance = struct('h', h_cen, 'p', p_cen);
stats_FigureS2B_right.con_vs_chance = struct('h', h_con, 'p', p_con);

%% Figure S2C

clear

addpath('../function');

rl_parameter = load('../model_analysis/Solo/RL/RL_chain.mat', ...
    'medianPosteriorLr', 'medianPosteriorInvTemp');
HBE = [rl_parameter.medianPosteriorLr rl_parameter.medianPosteriorInvTemp];

political_groups = load('../behavior_data/PoliticalGroups.mat', 'Centrism', 'Conservatism', 'Progressivism');

Pro_ID = political_groups.Progressivism(:,1);
Cen_ID = political_groups.Centrism(:,1);
Con_ID = political_groups.Conservatism(:,1);

exclude_subj = [1 14 50 57 67 71 73 74 82 90 109 112];
total_subj = setdiff(1:136, exclude_subj);

para = NaN(136, size(HBE, 2));
para(total_subj,:) = HBE;

Group = [political_groups.Progressivism(:,2); political_groups.Centrism(:,2); political_groups.Conservatism(:,2)];
colors = {[0 0 1]; [0 0 0]; [1 0 0]};

Lr = [para(Pro_ID,1); para(Cen_ID,1); para(Con_ID,1)];
InvTemp = [para(Pro_ID,2); para(Cen_ID,2); para(Con_ID,2)];

figure('Position', [500, 500, 320, 280]);
violins = violinplot(Lr, Group);
hold on
for i = 1:length(violins)
    violins(i).ScatterPlot.SizeData = 150;
    violins(i).ViolinColor = colors(i,:);
    violins(i).ViolinPlot.LineWidth = 1;
    violins(i).WhiskerPlot.LineWidth = 1.5;
    violins(i).ScatterPlot.MarkerFaceAlpha = 0.35;
    violins(i).MedianPlot.SizeData = 200;
    violins(i).MedianPlot.LineWidth = 2.5;
    violins(i).BoxWidth = 0.02;
end
scatter(1, mean(para(Pro_ID,1)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 1],'LineWidth', 2);
scatter(2, mean(para(Cen_ID,1)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0],'LineWidth', 2);
scatter(3, mean(para(Con_ID,1)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [1 0 0],'LineWidth', 2);
ylim([0 1]);
yticks([0 0.5 1]);
set(gca, 'FontSize', 20, 'FontName', 'Arial', 'LineWidth', 2);
xticklabels({''});

% Inverse temperature
figure('Position', [500, 500, 320, 280]);
violins = violinplot(InvTemp, Group);
hold on
for i = 1:length(violins)
    violins(i).ScatterPlot.SizeData = 150;
    violins(i).ViolinColor = colors(i,:);
    violins(i).ViolinPlot.LineWidth = 1;
    violins(i).WhiskerPlot.LineWidth = 1.5;
    violins(i).ScatterPlot.MarkerFaceAlpha = 0.35;
    violins(i).MedianPlot.SizeData = 200;
    violins(i).MedianPlot.LineWidth = 2.5;
    violins(i).BoxWidth = 0.02;
end
scatter(1, mean(para(Pro_ID,2)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 1],'LineWidth', 2);
scatter(2, mean(para(Cen_ID,2)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0],'LineWidth', 2);
scatter(3, mean(para(Con_ID,2)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [1 0 0],'LineWidth', 2);
ylim([0 10]);
yticks([0 5 10]);
set(gca, 'FontSize', 20, 'FontName', 'Arial', 'LineWidth', 2);
xticklabels({''});
