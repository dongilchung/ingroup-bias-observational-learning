%% Figure S4

%% Figure S4B

clear
close all

ol_data = load('../behavior_data/OL/OL_Indiv_data.mat', ...
    'data_indiv_8', 'data_indiv_10', 'data_indiv_12', 'total_subj');

data_blocks = {ol_data.data_indiv_8, ol_data.data_indiv_10, ol_data.data_indiv_12};
total_subj = ol_data.total_subj;
figure_s4_ol_ready = true;

n_all_subjects = 136;
COL_GROUP = 3;
COL_PARTNER_CHOICE = 4;
COL_PARTNER_REWARD = 5;
COL_SELF_CHOICE = 9;

total_win_count = zeros(n_all_subjects, 1);
total_lose_count = zeros(n_all_subjects, 1);
total_win_stay_count = zeros(n_all_subjects, 1);
total_lose_shift_count = zeros(n_all_subjects, 1);

for subj = total_subj
    for p = 1:numel(data_blocks)
        block_data = data_blocks{p}{subj};

        win_trials = block_data(:, COL_PARTNER_REWARD) == 1;
        lose_trials = block_data(:, COL_PARTNER_REWARD) ~= 1;
        stay_trials = block_data(:, COL_SELF_CHOICE) == block_data(:, COL_PARTNER_CHOICE);
        shift_trials = block_data(:, COL_SELF_CHOICE) ~= block_data(:, COL_PARTNER_CHOICE);

        total_win_count(subj) = total_win_count(subj) + nnz(win_trials);
        total_lose_count(subj) = total_lose_count(subj) + nnz(lose_trials);
        total_win_stay_count(subj) = total_win_stay_count(subj) + nnz(win_trials & stay_trials);
        total_lose_shift_count(subj) = total_lose_shift_count(subj) + nnz(lose_trials & shift_trials);
    end
end

WS = total_win_stay_count ./ total_win_count;
LS = total_lose_shift_count ./ total_lose_count;
WSLS = (total_win_stay_count + total_lose_shift_count) ./ (total_win_count + total_lose_count);

mean_WS = mean(WS(total_subj), 'omitnan');
sem_WS = std(WS(total_subj), 0, 'omitnan') ./ sqrt(numel(total_subj));
mean_LS = mean(LS(total_subj), 'omitnan');
sem_LS = std(LS(total_subj), 0, 'omitnan') ./ sqrt(numel(total_subj));
mean_WSLS = mean(WSLS(total_subj), 'omitnan');
sem_WSLS = std(WSLS(total_subj), 0, 'omitnan') ./ sqrt(numel(total_subj));

means = [mean_WS, mean_LS];
sems = [sem_WS, sem_LS];
colors = [0.75 0.75 0.75; 0.75 0.75 0.75];

figure('color', 'w', 'Position', [500, 500, 320, 280]);
bar(1:2, means, 'FaceColor', 'flat', 'CData', colors, 'LineWidth', 2);
hold on;
err = errorbar(1:2, means, sems, 'k', 'linestyle', 'none', 'LineWidth', 3);
err.CapSize = 20;
err.LineWidth = 3;
yline(0.5, '--', 'Color', 'k', 'LineWidth', 2);
set(gca, 'XTick', 1:2, 'XTickLabel', {'', ''}, 'FontSize', 18, 'LineWidth', 2);

[h_ws, p_ws, ci_ws, ttest_stats_ws] = ttest(WS, 0.5);
[h_ls, p_ls, ci_ls, ttest_stats_ls] = ttest(LS, 0.5);

stats_FigureS4B = struct();
stats_FigureS4B.means = means;
stats_FigureS4B.sems = sems;
stats_FigureS4B.mean_WSLS = mean_WSLS;
stats_FigureS4B.sem_WSLS = sem_WSLS;
stats_FigureS4B.WS_vs_chance = struct('h', h_ws, 'p', p_ws, 'ci', ci_ws, 'stats', ttest_stats_ws);
stats_FigureS4B.LS_vs_chance = struct('h', h_ls, 'p', p_ls, 'ci', ci_ls, 'stats', ttest_stats_ls);

%% Figure S4C

if ~exist('figure_s4_ol_ready', 'var') || ~figure_s4_ol_ready
    ol_data = load('../behavior_data/OL/OL_Indiv_data.mat', ...
        'data_indiv_8', 'data_indiv_10', 'data_indiv_12', 'total_subj');

    data_blocks = {ol_data.data_indiv_8, ol_data.data_indiv_10, ol_data.data_indiv_12};
    total_subj = ol_data.total_subj;
    figure_s4_ol_ready = true;

    n_all_subjects = 136;
    COL_GROUP = 3;
    COL_PARTNER_CHOICE = 4;
    COL_PARTNER_REWARD = 5;
    COL_SELF_CHOICE = 9;
end

total_In_win_count = zeros(n_all_subjects, 1);
total_In_lose_count = zeros(n_all_subjects, 1);
total_In_win_stay_count = zeros(n_all_subjects, 1);
total_In_lose_shift_count = zeros(n_all_subjects, 1);

total_Out_win_count = zeros(n_all_subjects, 1);
total_Out_lose_count = zeros(n_all_subjects, 1);
total_Out_win_stay_count = zeros(n_all_subjects, 1);
total_Out_lose_shift_count = zeros(n_all_subjects, 1);

for subj = total_subj
    for p = 1:numel(data_blocks)
        block_data = data_blocks{p}{subj};

        ingroup_trials = block_data(:, COL_GROUP) == 1;
        outgroup_trials = block_data(:, COL_GROUP) == 2;
        win_trials = block_data(:, COL_PARTNER_REWARD) == 1;
        lose_trials = block_data(:, COL_PARTNER_REWARD) ~= 1;
        stay_trials = block_data(:, COL_SELF_CHOICE) == block_data(:, COL_PARTNER_CHOICE);
        shift_trials = block_data(:, COL_SELF_CHOICE) ~= block_data(:, COL_PARTNER_CHOICE);

        total_In_win_count(subj) = total_In_win_count(subj) + nnz(ingroup_trials & win_trials);
        total_In_lose_count(subj) = total_In_lose_count(subj) + nnz(ingroup_trials & lose_trials);
        total_Out_win_count(subj) = total_Out_win_count(subj) + nnz(outgroup_trials & win_trials);
        total_Out_lose_count(subj) = total_Out_lose_count(subj) + nnz(outgroup_trials & lose_trials);

        total_In_win_stay_count(subj) = total_In_win_stay_count(subj) + nnz(ingroup_trials & win_trials & stay_trials);
        total_In_lose_shift_count(subj) = total_In_lose_shift_count(subj) + nnz(ingroup_trials & lose_trials & shift_trials);
        total_Out_win_stay_count(subj) = total_Out_win_stay_count(subj) + nnz(outgroup_trials & win_trials & stay_trials);
        total_Out_lose_shift_count(subj) = total_Out_lose_shift_count(subj) + nnz(outgroup_trials & lose_trials & shift_trials);
    end
end

In_WS = total_In_win_stay_count ./ total_In_win_count;
In_LS = total_In_lose_shift_count ./ total_In_lose_count;
In_WSLS = (total_In_win_stay_count + total_In_lose_shift_count) ./ (total_In_win_count + total_In_lose_count);

Out_WS = total_Out_win_stay_count ./ total_Out_win_count;
Out_LS = total_Out_lose_shift_count ./ total_Out_lose_count;
Out_WSLS = (total_Out_win_stay_count + total_Out_lose_shift_count) ./ (total_Out_win_count + total_Out_lose_count);

mean_In_WS = mean(In_WS(total_subj,:), 'omitnan');
sem_In_WS = std(In_WS(total_subj,:), 0, 'omitnan') ./ sqrt(numel(total_subj));
mean_In_LS = mean(In_LS(total_subj,:), 'omitnan');
sem_In_LS = std(In_LS(total_subj,:), 0, 'omitnan') ./ sqrt(numel(total_subj));
mean_In_WSLS = mean(In_WSLS(total_subj,:), 'omitnan');
sem_In_WSLS = std(In_WSLS(total_subj,:), 0, 'omitnan') ./ sqrt(numel(total_subj));

mean_Out_WS = mean(Out_WS(total_subj,:), 'omitnan');
sem_Out_WS = std(Out_WS(total_subj,:), 0, 'omitnan') ./ sqrt(numel(total_subj));
mean_Out_LS = mean(Out_LS(total_subj,:), 'omitnan');
sem_Out_LS = std(Out_LS(total_subj,:), 0, 'omitnan') ./ sqrt(numel(total_subj));
mean_Out_WSLS = mean(Out_WSLS(total_subj,:), 'omitnan');
sem_Out_WSLS = std(Out_WSLS(total_subj,:), 0, 'omitnan') ./ sqrt(numel(total_subj));

means = [mean_In_WS, mean_Out_WS; mean_In_LS, mean_Out_LS];
sems = [sem_In_WS, sem_Out_WS; sem_In_LS, sem_Out_LS];
colors = [0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
numGroups = size(means, 1);

figure('Position', [500, 500, 320, 280]);
b = bar(means, 'grouped', 'LineWidth',2);
for i = 1:numGroups
    b(i).FaceColor = colors(i, :);
end
nBars = size(means, 2);
groupWidth = min(0.8, nBars/(nBars + 1.5));
hold on;
for i = 1:nBars
    x = (1:numGroups) - groupWidth/2 + (2*i-1) * groupWidth / (2*nBars);
    err = errorbar(x, means(:, i), sems(:, i), 'k', 'LineStyle', 'none', 'LineWidth', 3);
    err.CapSize = 15;
end
set(gca, 'XTick', 1:2, 'XTickLabel', {'', ''}, 'FontSize', 18, 'LineWidth', 2);
legend({'Ingroup', 'Outgroup'}, 'FontSize', 14);
hold off;

[h_ws, p_ws, ci_ws, ttest_stats_ws] = ttest(In_WS, Out_WS);
[h_ls, p_ls, ci_ls, ttest_stats_ls] = ttest(In_LS, Out_LS);

stats_FigureS4C = struct();
stats_FigureS4C.means = means;
stats_FigureS4C.sems = sems;
stats_FigureS4C.mean_In_WSLS = mean_In_WSLS;
stats_FigureS4C.sem_In_WSLS = sem_In_WSLS;
stats_FigureS4C.mean_Out_WSLS = mean_Out_WSLS;
stats_FigureS4C.sem_Out_WSLS = sem_Out_WSLS;
stats_FigureS4C.In_vs_Out_WS = struct('h', h_ws, 'p', p_ws, 'ci', ci_ws, 'stats', ttest_stats_ws);
stats_FigureS4C.In_vs_Out_LS = struct('h', h_ls, 'p', p_ls, 'ci', ci_ls, 'stats', ttest_stats_ls);

%% Figure S4D

political_groups = load('../behavior_data/PoliticalGroups.mat', 'Centrism', 'Conservatism', 'Progressivism');

Pro_ID = political_groups.Progressivism(:,1);
Cen_ID = political_groups.Centrism(:,1);
Con_ID = political_groups.Conservatism(:,1);

wsls_group = load('../behavior_data/OL/WSLS_Group.mat', ...
    'WS_Pro', 'LS_Pro', 'WS_Cen', 'LS_Cen', 'WS_Con', 'LS_Con');

WS_Pro = wsls_group.WS_Pro;
LS_Pro = wsls_group.LS_Pro;
WS_Cen = wsls_group.WS_Cen;
LS_Cen = wsls_group.LS_Cen;
WS_Con = wsls_group.WS_Con;
LS_Con = wsls_group.LS_Con;

mean_WS_Pro = mean(WS_Pro, 'omitnan');
sem_WS_Pro = std(WS_Pro, 0, 'omitnan') ./ sqrt(numel(Pro_ID));
mean_LS_Pro = mean(LS_Pro, 'omitnan');
sem_LS_Pro = std(LS_Pro, 0, 'omitnan') ./ sqrt(numel(Pro_ID));

mean_WS_Cen = mean(WS_Cen, 'omitnan');
sem_WS_Cen = std(WS_Cen, 0, 'omitnan') ./ sqrt(numel(Cen_ID));
mean_LS_Cen = mean(LS_Cen, 'omitnan');
sem_LS_Cen = std(LS_Cen, 0, 'omitnan') ./ sqrt(numel(Cen_ID));

mean_WS_Con = mean(WS_Con, 'omitnan');
sem_WS_Con = std(WS_Con, 0, 'omitnan') ./ sqrt(numel(Con_ID));
mean_LS_Con = mean(LS_Con, 'omitnan');
sem_LS_Con = std(LS_Con, 0, 'omitnan') ./ sqrt(numel(Con_ID));

data = [mean_WS_Pro mean_WS_Cen mean_WS_Con; ...
    mean_LS_Pro mean_LS_Cen mean_LS_Con];
sem_data = [sem_WS_Pro sem_WS_Cen sem_WS_Con; ...
    sem_LS_Pro sem_LS_Cen sem_LS_Con];

numGroups = size(data, 1);
numBars = size(data, 2);
groupWidth = min(0.8, numBars/(numBars + 1.5));

figure('color', 'w', 'Position', [500, 500, 320, 280]);
hold on;
b = bar(data, 'grouped', 'LineWidth', 2);

b(1).FaceColor = 'b';
b(2).FaceColor = [0.5 0.5 0.5];
b(3).FaceColor = 'r';

for i = 1:numBars
    x = (1:numGroups) - groupWidth/2 + (2*i-1) * groupWidth / (2*numBars);
    errorbar(x, data(:,i), sem_data(:,i), 'k', 'linestyle', 'none', 'LineWidth', 2);
end

legend({'Lib', 'Mod', 'Con'}, 'FontSize', 12);
xticks(1:2);
xticklabels({'', ''});
set(gca, 'FontSize', 20, 'LineWidth', 2);

hold off;

stats_FigureS4D = struct();
stats_FigureS4D.data = data;
stats_FigureS4D.sem = sem_data;

%% Figure S4E,F

political_groups = load('../behavior_data/PoliticalGroups.mat', 'Centrism', 'Conservatism', 'Progressivism');

Pro_ID = political_groups.Progressivism(:,1);
Cen_ID = political_groups.Centrism(:,1);
Con_ID = political_groups.Conservatism(:,1);

wsls_inout = load('../behavior_data/OL/WSLS_InOut.mat', ...
    'In_WS', 'In_LS', 'Out_WS', 'Out_LS');

In_WS = wsls_inout.In_WS;
In_LS = wsls_inout.In_LS;
Out_WS = wsls_inout.Out_WS;
Out_LS = wsls_inout.Out_LS;

In_WS_Pro = In_WS(Pro_ID,:);
In_WS_Cen = In_WS(Cen_ID,:);
In_WS_Con = In_WS(Con_ID,:);
Out_WS_Pro = Out_WS(Pro_ID,:);
Out_WS_Cen = Out_WS(Cen_ID,:);
Out_WS_Con = Out_WS(Con_ID,:);

figure('color', 'w', 'Position', [500, 500, 280, 240]);
Pro = In_WS_Pro - Out_WS_Pro;
Cen = In_WS_Cen - Out_WS_Cen;
Con = In_WS_Con - Out_WS_Con;

mean_Pro = mean(Pro);
mean_Cen = mean(Cen);
mean_Con = mean(Con);
sem_Pro = std(Pro) / sqrt(numel(Pro_ID));
sem_Cen = std(Cen) / sqrt(numel(Cen_ID));
sem_Con = std(Con) / sqrt(numel(Con_ID));

barData = [mean_Pro, mean_Cen, mean_Con];
sem_barData = [sem_Pro, sem_Cen, sem_Con];

bar(1:3, barData, 'FaceColor', 'flat', 'CData', [0 0 1; 0 0 0; 1 0 0], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
hold on;
scatter(ones(size(Pro)) + 0.3*rand(size(Pro)) - 0.15, Pro, 40, 'b', 'filled');
scatter(2*ones(size(Cen)) + 0.3*rand(size(Cen)) - 0.15, Cen, 40, 'k', 'filled');
scatter(3*ones(size(Con)) + 0.3*rand(size(Con)) - 0.15, Con, 40, 'r', 'filled');

err = errorbar(1:3, barData, sem_barData, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'b');
err.CapSize = 15;
err = errorbar(2, mean_Cen, sem_Cen, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'k');
err.CapSize = 15;
err = errorbar(3, mean_Con, sem_Con, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'r');
err.CapSize = 15;

set(gca, 'XTick', 1:3, 'XTickLabel', {'', '', ''}, 'FontSize', 18);
ylim([-1 1]);
set(gca, 'YTick', [-1 -0.5 0 0.5 1]);
set(gca, 'LineWidth', 2);

hold off;

[h_pro, p_pro, ci_pro, ttest_stats_pro] = ttest(Pro);
[h_cen, p_cen, ci_cen, ttest_stats_cen] = ttest(Cen);
[h_con, p_con, ci_con, ttest_stats_con] = ttest(Con);

stats_FigureS4E = struct();
stats_FigureS4E.bar_data = barData;
stats_FigureS4E.sem = sem_barData;
stats_FigureS4E.pro_vs_zero = struct('h', h_pro, 'p', p_pro, 'ci', ci_pro, 'stats', ttest_stats_pro);
stats_FigureS4E.cen_vs_zero = struct('h', h_cen, 'p', p_cen, 'ci', ci_cen, 'stats', ttest_stats_cen);
stats_FigureS4E.con_vs_zero = struct('h', h_con, 'p', p_con, 'ci', ci_con, 'stats', ttest_stats_con);

In_LS_Pro = In_LS(Pro_ID,:);
In_LS_Cen = In_LS(Cen_ID,:);
In_LS_Con = In_LS(Con_ID,:);
Out_LS_Pro = Out_LS(Pro_ID,:);
Out_LS_Cen = Out_LS(Cen_ID,:);
Out_LS_Con = Out_LS(Con_ID,:);

figure('color', 'w', 'Position', [500, 500, 280, 240]);
Pro = In_LS_Pro - Out_LS_Pro;
Cen = In_LS_Cen - Out_LS_Cen;
Con = In_LS_Con - Out_LS_Con;

mean_Pro = mean(Pro);
mean_Cen = mean(Cen);
mean_Con = mean(Con);
sem_Pro = std(Pro) / sqrt(numel(Pro_ID));
sem_Cen = std(Cen) / sqrt(numel(Cen_ID));
sem_Con = std(Con) / sqrt(numel(Con_ID));

barData = [mean_Pro, mean_Cen, mean_Con];
sem_barData = [sem_Pro, sem_Cen, sem_Con];

bar(1:3, barData, 'FaceColor', 'flat', 'CData', [0 0 1; 0 0 0; 1 0 0], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
hold on;
scatter(ones(size(Pro)) + 0.3*rand(size(Pro)) - 0.15, Pro, 40, 'b', 'filled');
scatter(2*ones(size(Cen)) + 0.3*rand(size(Cen)) - 0.15, Cen, 40, 'k', 'filled');
scatter(3*ones(size(Con)) + 0.3*rand(size(Con)) - 0.15, Con, 40, 'r', 'filled');

err = errorbar(1:3, barData, sem_barData, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'b');
err.CapSize = 15;
err = errorbar(2, mean_Cen, sem_Cen, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'k');
err.CapSize = 15;
err = errorbar(3, mean_Con, sem_Con, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'r');
err.CapSize = 15;

set(gca, 'XTick', 1:3, 'XTickLabel', {'', '', ''}, 'FontSize', 18);
ylim([-1 1]);
set(gca, 'YTick', [-1 -0.5 0 0.5 1]);
set(gca, 'LineWidth', 2);

hold off;

[h_pro, p_pro, ci_pro, ttest_stats_pro] = ttest(Pro);
[h_cen, p_cen, ci_cen, ttest_stats_cen] = ttest(Cen);
[h_con, p_con, ci_con, ttest_stats_con] = ttest(Con);

stats_FigureS4F = struct();
stats_FigureS4F.bar_data = barData;
stats_FigureS4F.sem = sem_barData;
stats_FigureS4F.pro_vs_zero = struct('h', h_pro, 'p', p_pro, 'ci', ci_pro, 'stats', ttest_stats_pro);
stats_FigureS4F.cen_vs_zero = struct('h', h_cen, 'p', p_cen, 'ci', ci_cen, 'stats', ttest_stats_cen);
stats_FigureS4F.con_vs_zero = struct('h', h_con, 'p', p_con, 'ci', ci_con, 'stats', ttest_stats_con);
