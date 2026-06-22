%% Figure S6

clear
close all

political_groups = load('../behavior_data/PoliticalGroups.mat', 'Centrism', 'Conservatism', 'Progressivism');

Pro_ID = political_groups.Progressivism(:,1);
Cen_ID = political_groups.Centrism(:,1);
Con_ID = political_groups.Conservatism(:,1);

ol_data = load('../behavior_data/OL/OL_Indiv_data.mat', ...
    'data_indiv_8', 'data_indiv_10', 'data_indiv_12', 'total_subj');
data_blocks = {ol_data.data_indiv_8, ol_data.data_indiv_10, ol_data.data_indiv_12};
total_subj = ol_data.total_subj;

COL_PREDICTION_CHOICE = 7;
COL_SELF_CHOICE = 9;
n_all_subjects = numel(data_blocks{1});
n_transition_trials = (size(data_blocks{1}{total_subj(1)}, 1) - 1) * numel(data_blocks);

consistency = NaN(n_all_subjects, 1);
for subj = total_subj
    count = 0;
    for p = 1:numel(data_blocks)
        block_data = data_blocks{p}{subj};
        count = count + nnz(block_data(2:end, COL_PREDICTION_CHOICE) == block_data(1:end-1, COL_SELF_CHOICE));
    end
    consistency(subj,:) = count;
end

consistent_rate = consistency ./ n_transition_trials;

consistent_rate_Pro = consistent_rate(Pro_ID,:);
consistent_rate_Cen = consistent_rate(Cen_ID,:);
consistent_rate_Con = consistent_rate(Con_ID,:);

mean_consistent_rate_Pro = mean(consistent_rate_Pro);
mean_consistent_rate_Cen = mean(consistent_rate_Cen);
mean_consistent_rate_Con = mean(consistent_rate_Con);

sem_consistent_rate_Pro = std(consistent_rate_Pro) / sqrt(numel(Pro_ID));
sem_consistent_rate_Cen = std(consistent_rate_Cen) / sqrt(numel(Cen_ID));
sem_consistent_rate_Con = std(consistent_rate_Con) / sqrt(numel(Con_ID));

bar_data = [mean_consistent_rate_Pro mean_consistent_rate_Cen mean_consistent_rate_Con];
sem_data = [sem_consistent_rate_Pro sem_consistent_rate_Cen sem_consistent_rate_Con];

colors = [0 0 1; 0.5 0.5 0.5; 1 0 0];

figure('color', 'w', 'Position', [500, 500, 320, 280]);
b = bar(1:3, bar_data, 'FaceColor', 'flat', 'LineWidth', 2);
for k = 1:3
    b.CData(k,:) = colors(k,:);
end
hold on;
err = errorbar(1:3, bar_data, sem_data, 'k', 'linestyle', 'none', 'LineWidth', 3);
err.CapSize = 20;

yline(0.5, '--k','LineWidth',2);

xticks(1:3);
xticklabels({'',  '', ''});
set(gca, 'FontSize', 18, 'LineWidth', 2);
ylim([0 1]);
hold off;

groups = [zeros(size(Pro_ID)); ones(size(Cen_ID)); 2*ones(size(Con_ID))];
rate = [consistent_rate_Pro; consistent_rate_Cen; consistent_rate_Con];

[p_anova, tbl_anova, anova_stats] = anova1(rate, groups, 'off');

stats_FigureS6_group = struct();
stats_FigureS6_group.data = bar_data;
stats_FigureS6_group.sem = sem_data;
stats_FigureS6_group.anova = struct('p', p_anova, 'table', {tbl_anova}, 'stats', anova_stats);

mean_consistent_rate = mean(consistent_rate(total_subj,:), 'omitnan');
sem_consistent_rate = std(consistent_rate(total_subj,:)) / sqrt(numel(total_subj));

figure('color', 'w', 'Position', [500, 500, 320, 280]);
b = bar(1, mean_consistent_rate, 'FaceColor', 'flat', 'LineWidth', 2);
b.CData(1,:) = [.2 .2 .2];
hold on;
err = errorbar(1, mean_consistent_rate, sem_consistent_rate, 'k', 'linestyle', 'none', 'LineWidth', 3);
err.CapSize = 30;
yline(0.5, '--k','LineWidth',2);

xticks(1);
xticklabels({''});
set(gca, 'FontSize', 20, 'LineWidth', 2);
ylim([0 1]);
hold off;

[h_consistency, p_consistency] = ttest(consistent_rate(total_subj,:), 0.5);

stats_FigureS6_overall = struct();
stats_FigureS6_overall.mean = mean_consistent_rate;
stats_FigureS6_overall.sem = sem_consistent_rate;
stats_FigureS6_overall.vs_chance = struct('h', h_consistency, 'p', p_consistency);

% Correlation with Solo RL inverse temperature.
solo_rl_parameter = load('../model_analysis/Solo/RL/RL_chain.mat', 'medianPosteriorInvTemp');
solo_rl_invtemp = solo_rl_parameter.medianPosteriorInvTemp;

[r_solo_rl_invtemp, p_solo_rl_invtemp] = corr(solo_rl_invtemp, consistent_rate(total_subj,:));

figure('color', 'w', 'Position', [500, 500, 280, 240]);
hold on
scatter(solo_rl_invtemp, consistent_rate(total_subj,:), 80, 'k', 'filled');
solo_rl_invtemp_fit = fit(solo_rl_invtemp, consistent_rate(total_subj,:), 'poly1');
h = plot(solo_rl_invtemp_fit, 'r');
set(h, 'LineWidth', 4);
set(gca, 'FontSize', 18, 'LineWidth', 2);
xlabel({''}, 'FontSize', 10);
ylabel({''}, 'FontSize', 10);
legend off;

stats_FigureS6_solo_rl_invtemp = struct();
stats_FigureS6_solo_rl_invtemp.r = r_solo_rl_invtemp;
stats_FigureS6_solo_rl_invtemp.p = p_solo_rl_invtemp;
stats_FigureS6_solo_rl_invtemp.fit = solo_rl_invtemp_fit;
