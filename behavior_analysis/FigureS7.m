%% Figure S7

clear; close all
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'function'));

load('../model_analysis/OL/Model_RCImP4/OL_chain.mat', ...
    'medianPosteriorLr', 'medianPosteriorK', ...
    'medianPosteriorW1In', 'medianPosteriorW2In', ...
    'medianPosteriorW1Out', 'medianPosteriorW2Out', ...
    'medianPosteriorInvTemp');

HBE = [medianPosteriorLr medianPosteriorK medianPosteriorW1In medianPosteriorW2In medianPosteriorW1Out medianPosteriorW2Out medianPosteriorInvTemp];

% Learning rate
colors = {[0 0.4470 0.7410]};
figure('Position', [500, 500, 240, 200]);
violins = violinplot(HBE(:,1))
for i = 1:length(violins)
    violins(i).ScatterPlot.SizeData = 150;
    violins(i).ViolinColor = colors;
    violins(i).ViolinPlot.LineWidth = 1;
    violins(i).WhiskerPlot.LineWidth = 1.5;
    violins(i).ScatterPlot.MarkerFaceAlpha = 0.35;
    violins(i).MedianPlot.SizeData = 200;
    violins(i).MedianPlot.LineWidth = 2.5;
    violins(i).BoxWidth = 0.007;
end
scatter(1, mean(HBE(:,1)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0.4470 0.7410], 'LineWidth', 2)
ylim([0 1])
set(gca, 'FontSize', 16, 'LineWidth', 2);
xticklabels({''});

% Action Learning rate
colors = {[0.4940 0.1840 0.5560]};
figure('Position', [500, 500, 240, 200]);
violins = violinplot(HBE(:,2))
for i = 1:length(violins)
    violins(i).ScatterPlot.SizeData = 150;
    violins(i).ViolinColor = colors;
    violins(i).ViolinPlot.LineWidth = 1;
    violins(i).WhiskerPlot.LineWidth = 1.5;
    violins(i).ScatterPlot.MarkerFaceAlpha = 0.35;
    violins(i).MedianPlot.SizeData = 200;
    violins(i).MedianPlot.LineWidth = 2.5;
    violins(i).BoxWidth = 0.007;
end
scatter(1, mean(HBE(:,2)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0.4940 0.1840 0.5560], 'LineWidth', 2)
ylim([0 1])
set(gca, 'FontSize', 16, 'LineWidth', 2);
xticklabels({''});

% Inverse temperature
colors = {[0.6350 0.0780 0.1840]};
figure('Position', [500, 500, 240, 200]);
violins = violinplot(HBE(:,7))
for i = 1:length(violins)
    violins(i).ScatterPlot.SizeData = 150;
    violins(i).ViolinColor = colors(i,:);
    violins(i).ViolinPlot.LineWidth = 1;
    violins(i).WhiskerPlot.LineWidth = 1.5;
    violins(i).ScatterPlot.MarkerFaceAlpha = 0.35;
    violins(i).MedianPlot.SizeData = 200;
    violins(i).MedianPlot.LineWidth = 2.5;
    violins(i).BoxWidth = 0.007;
end
scatter(1, mean(HBE(:,7)), 125, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0.6350 0.0780 0.1840], 'LineWidth', 2)
ylim([0 10])
set(gca, 'FontSize', 16, 'LineWidth', 2);
xticklabels({''});
