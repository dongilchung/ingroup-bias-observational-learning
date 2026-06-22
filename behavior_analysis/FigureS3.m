%% Figure S3

clear
close all

political_groups = load('../behavior_data/PoliticalGroups.mat', 'Centrism', 'Conservatism', 'Progressivism');

Pro_ID = political_groups.Progressivism(:,1)';
Cen_ID = political_groups.Centrism(:,1)';
Con_ID = political_groups.Conservatism(:,1)';

ol_data = load('../behavior_data/OL/OL_Indiv_data.mat', 'rev_total_data_indiv', 'total_subj');
rev_total_data_indiv = ol_data.rev_total_data_indiv;
total_subj = ol_data.total_subj;

COL_SELF_CHOICE = 9;
n_all_subjects = numel(rev_total_data_indiv);

self_rate = NaN(n_all_subjects, 1);
for subj = total_subj
    self_rate(subj,1) = mean(rev_total_data_indiv{subj}(:, COL_SELF_CHOICE));
end

self_rate_Pro = self_rate(Pro_ID,:);
self_rate_Cen = self_rate(Cen_ID,:);
self_rate_Con = self_rate(Con_ID,:);

total_self_rate_Pro = mean(self_rate_Pro, 'all');
total_self_rate_Cen = mean(self_rate_Cen, 'all');
total_self_rate_Con = mean(self_rate_Con, 'all');
sem_total_self_rate_Pro = std(self_rate_Pro) / sqrt(numel(Pro_ID));
sem_total_self_rate_Cen = std(self_rate_Cen) / sqrt(numel(Cen_ID));
sem_total_self_rate_Con = std(self_rate_Con) / sqrt(numel(Con_ID));

data = [total_self_rate_Pro total_self_rate_Cen total_self_rate_Con];
sem_data = [sem_total_self_rate_Pro sem_total_self_rate_Cen sem_total_self_rate_Con];

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

[h_pro_con, p_pro_con] = ttest2(self_rate_Pro, self_rate_Con);
[h_pro, p_pro] = ttest(self_rate_Pro, 0.5);
[h_cen, p_cen] = ttest(self_rate_Cen, 0.5);
[h_con, p_con] = ttest(self_rate_Con, 0.5);

stats_FigureS3 = struct();
stats_FigureS3.data = data;
stats_FigureS3.sem = sem_data;
stats_FigureS3.pro_vs_con = struct('h', h_pro_con, 'p', p_pro_con);
stats_FigureS3.pro_vs_chance = struct('h', h_pro, 'p', p_pro);
stats_FigureS3.cen_vs_chance = struct('h', h_cen, 'p', p_cen);
stats_FigureS3.con_vs_chance = struct('h', h_con, 'p', p_con);
