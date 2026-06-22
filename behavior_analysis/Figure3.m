%% Figure 3

%% Figure 3A

clear; close all
addpath('../function');
addpath('../model_analysis/OL/Model_RCImP4');
addpath('../behavior_data');

load('OL_chain.mat');
load('PoliticalGroups.mat', 'Centrism', 'Conservatism', 'Progressivism');

HBE = [medianPosteriorW1In medianPosteriorW2In medianPosteriorW1Out medianPosteriorW2Out];

% Pred bias
condition_colors = {[0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]};
figure('Position', [500, 500, 240, 200]);
violins = violinplot(HBE(:,[1 3]));
for i = 1:length(violins)
    violins(i).ScatterPlot.SizeData = 150;
    violins(i).ViolinColor = condition_colors(i,:);
    violins(i).ViolinPlot.LineWidth = 1;
    violins(i).WhiskerPlot.LineWidth = 1.5;
    violins(i).ScatterPlot.MarkerFaceAlpha = 0.35;
    violins(i).MedianPlot.SizeData = 200;
    violins(i).MedianPlot.LineWidth = 2.5;
    violins(i).BoxWidth = 0.015;
end
scatter(1, mean(HBE(:,1)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', condition_colors{1}, 'LineWidth', 2);
scatter(2, mean(HBE(:,3)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', condition_colors{2}, 'LineWidth', 2);
yline(0, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 2);
yticks([-1 -0.5 0 0.5 1]);
ylim([-1 1.2]);
set(gca, 'FontSize', 20, 'LineWidth', 2);
xticklabels({'', ''});

figure('Position', [500, 500, 240, 200]);
violins = violinplot(HBE(:,[2 4]));
for i = 1:length(violins)
    violins(i).ScatterPlot.SizeData = 150;
    violins(i).ViolinColor = condition_colors(i,:);
    violins(i).ViolinPlot.LineWidth = 1;
    violins(i).WhiskerPlot.LineWidth = 1.5;
    violins(i).ScatterPlot.MarkerFaceAlpha = 0.35;
    violins(i).MedianPlot.SizeData = 200;
    violins(i).MedianPlot.LineWidth = 2.5;
    violins(i).BoxWidth = 0.015;
end
scatter(1, mean(HBE(:,2)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', condition_colors{1}, 'LineWidth', 2);
scatter(2, mean(HBE(:,4)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', condition_colors{2}, 'LineWidth', 2);
yline(0, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 2);
yticks([-1 -0.5 0 0.5 1]);
ylim([-1 1.2]);
set(gca, 'FontSize', 20, 'LineWidth', 2);
xticklabels({'',''});

[stats_Figure3A.h_W1In, stats_Figure3A.p_W1In, stats_Figure3A.ci_W1In, stats_Figure3A.ttest_W1In] = ttest(medianPosteriorW1In);
[stats_Figure3A.h_W1Out, stats_Figure3A.p_W1Out, stats_Figure3A.ci_W1Out, stats_Figure3A.ttest_W1Out] = ttest(medianPosteriorW1Out);
[stats_Figure3A.h_W2In, stats_Figure3A.p_W2In, stats_Figure3A.ci_W2In, stats_Figure3A.ttest_W2In] = ttest(medianPosteriorW2In);
[stats_Figure3A.h_W2Out, stats_Figure3A.p_W2Out, stats_Figure3A.ci_W2Out, stats_Figure3A.ttest_W2Out] = ttest(medianPosteriorW2Out);

[stats_Figure3A.h_W1In_vs_W2In, stats_Figure3A.p_W1In_vs_W2In, stats_Figure3A.ci_W1In_vs_W2In, stats_Figure3A.ttest_W1In_vs_W2In] = ttest(medianPosteriorW1In, medianPosteriorW2In);
[stats_Figure3A.h_W1Out_vs_W2Out, stats_Figure3A.p_W1Out_vs_W2Out, stats_Figure3A.ci_W1Out_vs_W2Out, stats_Figure3A.ttest_W1Out_vs_W2Out] = ttest(medianPosteriorW1Out, medianPosteriorW2Out);

%%% Group bias (Pol group)
%% Figure 3B

addpath('../function');
addpath('../model_analysis/OL/Model_RCImP4');
addpath('../behavior_data');

if ~exist('HBE', 'var') || ~exist('Progressivism', 'var') || ~exist('Centrism', 'var') || ~exist('Conservatism', 'var')
    load('OL_chain.mat');
    load('PoliticalGroups.mat', 'Centrism', 'Conservatism', 'Progressivism');
    HBE = [medianPosteriorW1In medianPosteriorW2In medianPosteriorW1Out medianPosteriorW2Out];
end

Pro_ID = Progressivism(:,1);
Cen_ID = Centrism(:,1);
Con_ID = Conservatism(:,1);

n_all_subj = 136;
para = NaN(n_all_subj,size(HBE,2));
exclude_subj = [1 14 50 57 67 71 73 74 82 90 109 112];
total_subj = setdiff(1:n_all_subj, exclude_subj);
para(total_subj,:) = HBE;

Group = [Progressivism(:,2); Centrism(:,2); Conservatism(:,2)];
group_colors = {[0 0 1]; [0 0 0]; [1 0 0]};

W1In = [para(Pro_ID,1); para(Cen_ID,1); para(Con_ID,1)];
W2In = [para(Pro_ID,2); para(Cen_ID,2); para(Con_ID,2)];
W1Out = [para(Pro_ID,3); para(Cen_ID,3); para(Con_ID,3)];
W2Out = [para(Pro_ID,4); para(Cen_ID,4); para(Con_ID,4)];

% Win (In - Out)
figure('Position', [500, 500, 240, 200]);
violins = violinplot(W1In - W1Out, Group);
for i = 1:length(violins)
    violins(i).ScatterPlot.SizeData = 150;
    violins(i).ViolinColor = group_colors(i,:);
    violins(i).ViolinPlot.LineWidth = 1;
    violins(i).WhiskerPlot.LineWidth = 1.5;
    violins(i).ScatterPlot.MarkerFaceAlpha = 0.35;
    violins(i).MedianPlot.SizeData = 200;
    violins(i).MedianPlot.LineWidth = 2.5;
    violins(i).BoxWidth = 0.02;
end
scatter(1, mean(para(Pro_ID,1)-para(Pro_ID,3)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', group_colors{1}, 'LineWidth', 2);
scatter(2, mean(para(Cen_ID,1)-para(Cen_ID,3)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', group_colors{2}, 'LineWidth', 2);
scatter(3, mean(para(Con_ID,1)-para(Con_ID,3)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', group_colors{3}, 'LineWidth', 2);
yline(0, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 2);
set(gca, 'FontSize', 20, 'LineWidth', 2);
xticklabels({''});
ylim([-1 2]);
yticks([-1 0 1 2]);

% Lose (In - Out)
figure('Position', [500, 500, 240, 200]);
violins = violinplot(W2In - W2Out, Group);
for i = 1:length(violins)
    violins(i).ScatterPlot.SizeData = 150;
    violins(i).ViolinColor = group_colors(i,:);
    violins(i).ViolinPlot.LineWidth = 1;
    violins(i).WhiskerPlot.LineWidth = 1.5;
    violins(i).ScatterPlot.MarkerFaceAlpha = 0.35;
    violins(i).MedianPlot.SizeData = 200;
    violins(i).MedianPlot.LineWidth = 2.5;
    violins(i).BoxWidth = 0.02;
end
scatter(1, mean(para(Pro_ID,2)-para(Pro_ID,4)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', group_colors{1}, 'LineWidth', 2);
scatter(2, mean(para(Cen_ID,2)-para(Cen_ID,4)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', group_colors{2}, 'LineWidth', 2);
scatter(3, mean(para(Con_ID,2)-para(Con_ID,4)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', group_colors{3}, 'LineWidth', 2);
yline(0, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 2);
set(gca, 'FontSize', 20, 'LineWidth', 2);
xticklabels({''});
ylim([-1.1 2]);
yticks([-1 0 1 2]);

% Group bias (Win)
win_group_bias.Pro = para(Pro_ID,1)-para(Pro_ID,3);
win_group_bias.Cen = para(Cen_ID,1)-para(Cen_ID,3);
win_group_bias.Con = para(Con_ID,1)-para(Con_ID,3);

stats_Figure3B.win_mean = [mean(win_group_bias.Pro), mean(win_group_bias.Cen), mean(win_group_bias.Con)];
stats_Figure3B.win_sem = [std(win_group_bias.Pro)./sqrt(length(Pro_ID)), std(win_group_bias.Cen)./sqrt(length(Cen_ID)), std(win_group_bias.Con)./sqrt(length(Con_ID))];

[stats_Figure3B.h_win_Pro, stats_Figure3B.p_win_Pro, stats_Figure3B.ci_win_Pro, stats_Figure3B.ttest_win_Pro] = ttest(win_group_bias.Pro);
[stats_Figure3B.h_win_Cen, stats_Figure3B.p_win_Cen, stats_Figure3B.ci_win_Cen, stats_Figure3B.ttest_win_Cen] = ttest(win_group_bias.Cen);
[stats_Figure3B.h_win_Con, stats_Figure3B.p_win_Con, stats_Figure3B.ci_win_Con, stats_Figure3B.ttest_win_Con] = ttest(win_group_bias.Con);

% Group bias (Lose)
lose_group_bias.Pro = para(Pro_ID,2)-para(Pro_ID,4);
lose_group_bias.Cen = para(Cen_ID,2)-para(Cen_ID,4);
lose_group_bias.Con = para(Con_ID,2)-para(Con_ID,4);

stats_Figure3B.lose_mean = [mean(lose_group_bias.Pro), mean(lose_group_bias.Cen), mean(lose_group_bias.Con)];
stats_Figure3B.lose_sem = [std(lose_group_bias.Pro)./sqrt(length(Pro_ID)), std(lose_group_bias.Cen)./sqrt(length(Cen_ID)), std(lose_group_bias.Con)./sqrt(length(Con_ID))];

[stats_Figure3B.h_lose_Pro, stats_Figure3B.p_lose_Pro, stats_Figure3B.ci_lose_Pro, stats_Figure3B.ttest_lose_Pro] = ttest(lose_group_bias.Pro);
[stats_Figure3B.h_lose_Cen, stats_Figure3B.p_lose_Cen, stats_Figure3B.ci_lose_Cen, stats_Figure3B.ttest_lose_Cen] = ttest(lose_group_bias.Cen);
[stats_Figure3B.h_lose_Con, stats_Figure3B.p_lose_Con, stats_Figure3B.ci_lose_Con, stats_Figure3B.ttest_lose_Con] = ttest(lose_group_bias.Con);

[stats_Figure3B.p_win_anova, stats_Figure3B.tbl_win_anova, stats_Figure3B.stats_win_anova] = anova1(W1In-W1Out, Group, 'off');
[stats_Figure3B.p_lose_anova, stats_Figure3B.tbl_lose_anova, stats_Figure3B.stats_lose_anova] = anova1(W2In-W2Out, Group, 'off');

[stats_Figure3B.h_lose_Pro_vs_Cen, stats_Figure3B.p_lose_Pro_vs_Cen, stats_Figure3B.ci_lose_Pro_vs_Cen, stats_Figure3B.ttest_lose_Pro_vs_Cen] = ttest2(lose_group_bias.Pro, lose_group_bias.Cen);
[stats_Figure3B.h_lose_Pro_vs_Con, stats_Figure3B.p_lose_Pro_vs_Con, stats_Figure3B.ci_lose_Pro_vs_Con, stats_Figure3B.ttest_lose_Pro_vs_Con] = ttest2(lose_group_bias.Pro, lose_group_bias.Con);
[stats_Figure3B.h_lose_Cen_vs_Con, stats_Figure3B.p_lose_Cen_vs_Con, stats_Figure3B.ci_lose_Cen_vs_Con, stats_Figure3B.ttest_lose_Cen_vs_Con] = ttest2(lose_group_bias.Cen, lose_group_bias.Con);

[stats_Figure3B.h_lose_Con_vs_Pro, stats_Figure3B.p_lose_Con_vs_Pro, stats_Figure3B.ci_lose_Con_vs_Pro, stats_Figure3B.ttest_lose_Con_vs_Pro] = ttest2(lose_group_bias.Con, lose_group_bias.Pro);
[stats_Figure3B.h_lose_Con_vs_Cen, stats_Figure3B.p_lose_Con_vs_Cen, stats_Figure3B.ci_lose_Con_vs_Cen, stats_Figure3B.ttest_lose_Con_vs_Cen] = ttest2(lose_group_bias.Con, lose_group_bias.Cen);
