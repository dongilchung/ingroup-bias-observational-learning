%% Figure S13

%% Figure S13A
clear
close all

addpath('../../function');

load('amygdala_volume.mat', 'amygdala_volume_by_subject_id');
load('../../behavior_data/PoliticalGroups.mat', ...
    'Centrism', 'Conservatism', 'Progressivism');

Pro_ID = Progressivism(:,1);
Cen_ID = Centrism(:,1);
Con_ID = Conservatism(:,1);

Group = [Progressivism(:,2); Centrism(:,2); Conservatism(:,2)];
colors = {[0 0 1]; [0 0 0]; [1 0 0]};
group_label = {'Progressivism', 'Centrism', 'Conservatism'};

Amygdala_vol_group = [amygdala_volume_by_subject_id(Pro_ID); ...
    amygdala_volume_by_subject_id(Cen_ID); ...
    amygdala_volume_by_subject_id(Con_ID)];
group_mean = [mean(amygdala_volume_by_subject_id(Pro_ID), 'omitnan'), ...
    mean(amygdala_volume_by_subject_id(Cen_ID), 'omitnan'), ...
    mean(amygdala_volume_by_subject_id(Con_ID), 'omitnan')];

figure('Position', [500, 500, 240, 200]);
violins = violinplot(Amygdala_vol_group, Group);
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
hold on;
for group_idx = 1:length(group_label)
    scatter(group_idx, group_mean(group_idx), 125, ...
        'MarkerEdgeColor', [0 0 0], ...
        'MarkerFaceColor', colors{group_idx}, ...
        'LineWidth', 2);
end
hold off;
set(gca, 'FontSize', 20, 'LineWidth', 2);
xticklabels(repmat({''}, 1, length(group_label)));

%% Figure S13B
addpath('../../function');

subjlist = setdiff(1:124,[4 44 92]);

load('../../model_analysis/OL/Model_RCImP4/OL_chain.mat', ...
    'medianPosteriorW2In', 'medianPosteriorW2Out');
load('amygdala_volume.mat', 'amygdala_volume');

lose_bias = medianPosteriorW2In - medianPosteriorW2Out;

figure('color', 'w', 'Position', [500, 500, 280, 240]);
[r, p] = corr(amygdala_volume(subjlist), lose_bias(subjlist), 'rows', 'complete');
scatter(amygdala_volume(subjlist), lose_bias(subjlist), 100, 'k', 'filled');
set(gca, 'FontSize', 18, 'LineWidth', 2);
hold on;
if p < 0.05
    f = fit(amygdala_volume(subjlist), lose_bias(subjlist), 'poly1');
    h = plot(f, 'r');
    set(h, 'LineWidth', 4);
end
legend off;
hold off;
ylabel('', 'FontSize', 24);
xlabel('', 'FontSize', 24);
