% CPM
% Refined from Park (PNU socialneurosciencelab)
% Copyright 2015 Xilin Shen and Emily Finn
% Run from Ref/MRI_analysis/CPM.

clear; clc;
close all;

condition_name = 'Pol';
behavior_name = 'LoseBias';
edge_sign = 'pos';
thresh = 0.01;
r_threshold = 0.2;

fc_file = ['resultsROI_Condition' condition_name '.mat'];
fc_mats_struct = load(fc_file, 'Z');
all_mats = fc_mats_struct.Z;

all_behav_table = readtable('Conn_ID.csv');
all_behav = all_behav_table.(behavior_name);

covariates = [ ...
    all_behav_table.PolOrient, ...
    all_behav_table.Age, ...
    all_behav_table.Gender, ...
    all_behav_table.Education];

valid_subjects = ~isnan(all_behav) & all(~isnan(covariates), 2);
all_behav = all_behav(valid_subjects);
all_mats = all_mats(:, :, valid_subjects);
covariates = covariates(valid_subjects, :);

X_cov = [zscore(covariates(:,1)), zscore(covariates(:,2)), ...
    covariates(:,3), zscore(covariates(:,4)), ones(length(all_behav), 1)];
b_cov = regress(all_behav, X_cov);
all_behav = all_behav - X_cov * b_cov;

no_sub = size(all_mats, 3);
no_node = size(all_mats, 1);
behav_pred_pos = NaN(no_sub, 1);
behav_pred_neg = NaN(no_sub, 1);
edge_count_pos = zeros(no_node, no_node);
edge_count_neg = zeros(no_node, no_node);

for leftout = 1:no_sub
    fprintf('Leaving out subj %d/%d...\n', leftout, no_sub);

    train_mats = all_mats;
    train_mats(:, :, leftout) = [];
    train_behav = all_behav;
    train_behav(leftout) = [];

    train_vcts = reshape(train_mats, [], no_sub - 1);
    [r_mat, p_mat] = corr(train_vcts', train_behav, 'type', 'Spearman');
    r_mat = reshape(r_mat, no_node, no_node);
    p_mat = reshape(p_mat, no_node, no_node);

    pos_mask = (r_mat > r_threshold) & (p_mat < thresh);
    neg_mask = (r_mat < -r_threshold) & (p_mat < thresh);

    test_mat = all_mats(:, :, leftout);

    if nnz(pos_mask) > 0
        edge_count_pos = edge_count_pos + pos_mask;
        train_sumpos = get_edge_strength(train_mats, pos_mask);
        b_pos = regress(train_behav, [train_sumpos, ones(no_sub - 1, 1)]);
        test_sumpos = sum(test_mat(pos_mask), 'all') / 2;
        behav_pred_pos(leftout) = b_pos(1) * test_sumpos + b_pos(2);
    end

    if nnz(neg_mask) > 0
        edge_count_neg = edge_count_neg + neg_mask;
        train_sumneg = get_edge_strength(train_mats, neg_mask);
        b_neg = regress(train_behav, [train_sumneg, ones(no_sub - 1, 1)]);
        test_sumneg = sum(test_mat(neg_mask), 'all') / 2;
        behav_pred_neg(leftout) = b_neg(1) * test_sumneg + b_neg(2);
    end
end

valid_pos = ~isnan(behav_pred_pos) & ~isnan(all_behav);
valid_neg = ~isnan(behav_pred_neg) & ~isnan(all_behav);
[r_pos, p_pos] = corr(behav_pred_pos(valid_pos), all_behav(valid_pos), 'Type', 'Spearman');
[r_neg, p_neg] = corr(behav_pred_neg(valid_neg), all_behav(valid_neg), 'Type', 'Spearman');

fprintf('\nCPM prediction results (Spearman, covariates controlled):\n');
fprintf('Positive edges: r = %.3f, p = %.4f\n', r_pos, p_pos);
fprintf('Negative edges: r = %.3f, p = %.4f\n', r_neg, p_neg);

pos_edges = triu(edge_count_pos > 0, 1);
neg_edges = triu(edge_count_neg > 0, 1);
fprintf('\n[Edge Counts]\n');
fprintf('Positive edges: %d\n', nnz(pos_edges));
fprintf('Negative edges: %d\n', nnz(neg_edges));

selected_model_idx = find(strcmp(edge_sign, {'pos', 'neg'}));
if isempty(selected_model_idx)
    error('edge_sign must be ''pos'' or ''neg''.');
end

shen_table = readtable('shen268_coords.csv');
edge_counts = {edge_count_pos, edge_count_neg};
edge_labels = {'Positive', 'Negative'};
report_top_nodes(edge_counts{selected_model_idx}, shen_table, edge_labels{selected_model_idx});

models = {'Positive-edge Model', 'Negative-edge Model'};
predictions = {behav_pred_pos, behav_pred_neg};
valid_predictions = {valid_pos, valid_neg};
colors = [0.9 0.18 0.39; 0.2 0.4 0.8];

for model_idx = selected_model_idx
    pred = predictions{model_idx};
    valid_idx = valid_predictions{model_idx};

    figure('Color','w', 'Position', [100, 100, 360, 320]);
    scatter(pred(valid_idx), all_behav(valid_idx), 100, colors(model_idx,:), ...
        'filled', 'MarkerFaceAlpha', 0.25, 'MarkerEdgeColor', 'k');
    hold on;

    coeffs = polyfit(pred(valid_idx), all_behav(valid_idx), 1);
    x_fit = linspace(min(pred(valid_idx)), max(pred(valid_idx)), 100);
    y_fit = polyval(coeffs, x_fit);
    plot(x_fit, y_fit, '-', 'Color', colors(model_idx,:), 'LineWidth', 4);
    set(gca, 'FontSize', 18, 'Box', 'off', 'LineWidth', 2);
    title(models{model_idx});
    hold off;
end

function edge_strength = get_edge_strength(mats, mask)
edge_strength = zeros(size(mats, 3), 1);
for subj_idx = 1:size(mats, 3)
    mat = mats(:, :, subj_idx);
    edge_strength(subj_idx) = sum(mat(mask), 'all') / 2;
end
end

function report_top_nodes(edge_count, shen_table, label)
edge_presence = edge_count > 0;
edge_presence(1:size(edge_presence, 1)+1:end) = false;
node_degree = sum(edge_presence, 2);
[sorted_degree, sorted_idx] = sort(node_degree, 'descend');
top_nodes = sorted_idx(1:min(10, length(sorted_idx)));

fprintf('\n[Top Nodes by %s Edges]\n', label);
fprintf('Node | Degree | MNI Coordinates (X, Y, Z) | Region | Network\n');
fprintf('--------------------------------------------------------------------------\n');

for node_idx = 1:length(top_nodes)
    node_id = top_nodes(node_idx);
    coords = [shen_table.MNI_X(node_id), shen_table.MNI_Y(node_id), shen_table.MNI_Z(node_id)];
    region_name = char(string(shen_table.Region(node_id)));
    network_name = char(string(shen_table.Network(node_id)));

    fprintf('%4d | %6d | (%6.1f, %6.1f, %6.1f) | %s | %s\n', ...
        node_id, sorted_degree(node_idx), coords(1), coords(2), coords(3), ...
        region_name, network_name);
end
end
