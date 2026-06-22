clear; clc; close all;

script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end

condition_name = 'pol';
edge_signs = {'pos', 'neg'};
show_axis_labels = true;

net_order = {'MF', 'FP', 'DM', 'MT', 'VI', 'VII', 'VA', 'SA', 'SB', 'CB'};
net_labels = {'Medial Frontal', 'Frontoparietal', 'Default Mode', 'Motor', ...
    'Visual I', 'Visual II', 'Visual Association', 'Salience', 'Subcortical', 'Cerebellum'};

network_table = readtable(fullfile(script_dir, 'Shen268_10network_name.csv'));
network_ids = map_nodes_to_networks(network_table, net_order);

for edge_idx = 1:numel(edge_signs)
    edge_sign = edge_signs{edge_idx};
    edge_file = fullfile(script_dir, ...
        sprintf('connectivity_threshold_%s_binary_%s.csv', edge_sign, condition_name));
    edge_binary = readmatrix(edge_file);

    net_edge_count = count_network_edges(edge_binary, network_ids, numel(net_order));

    fprintf('\n%s edges, %s condition:\n', upper(edge_sign), upper(condition_name));
    disp(array2table(net_edge_count, 'VariableNames', net_order, 'RowNames', net_order));

    output_file = fullfile(script_dir, sprintf('edge_matrix_%s_%s.png', edge_sign, condition_name));
    plot_network_edge_matrix(net_edge_count, edge_sign, net_order, net_labels, show_axis_labels, output_file);
end

function network_ids = map_nodes_to_networks(network_table, net_order)
network_names = string(network_table.network);
network_ids = zeros(height(network_table), 1);

for node_idx = 1:height(network_table)
    match_idx = find(strcmp(network_names(node_idx), net_order), 1);
    if isempty(match_idx)
        error('Unknown network label for node %d: %s', node_idx, network_names(node_idx));
    end
    network_ids(node_idx) = match_idx;
end
end

function net_edge_count = count_network_edges(edge_binary, network_ids, no_network)
no_node = numel(network_ids);
net_edge_count = zeros(no_network, no_network);

for node_i = 1:no_node
    for node_j = node_i + 1:no_node
        if edge_binary(node_i, node_j) == 1
            net_i = network_ids(node_i);
            net_j = network_ids(node_j);
            net_edge_count(net_i, net_j) = net_edge_count(net_i, net_j) + 1;

            if net_i ~= net_j
                net_edge_count(net_j, net_i) = net_edge_count(net_j, net_i) + 1;
            end
        end
    end
end
end

function plot_network_edge_matrix(net_edge_count, edge_sign, net_order, net_labels, show_axis_labels, output_file)
no_network = numel(net_order);
[x_grid, y_grid] = meshgrid(1:no_network, 1:no_network);
lower_triangle_mask = tril(true(no_network, no_network), 0);
x_all = x_grid(lower_triangle_mask);
y_all = y_grid(lower_triangle_mask);
v_all = net_edge_count(lower_triangle_mask);

valid_idx = ~isnan(v_all) & v_all ~= 0;
x = x_all(valid_idx);
y = y_all(valid_idx);
v = v_all(valid_idx);

size_scale = 470;
if isempty(v)
    marker_sizes = [];
    max_val = 1;
elseif range(abs(v)) == 0
    marker_sizes = repmat(size_scale / 2, size(v));
    max_val = max(v);
else
    normed = normalize(abs(v), 'range');
    normed(normed <= 0) = 0.01;
    marker_sizes = size_scale * normed;
    max_val = max(v);
end

figure('Position', [100, 100, 520, 520]);
scatter(x, y, marker_sizes, v, 's', ...
    'MarkerEdgeColor', 'k', ...
    'MarkerFaceColor', 'flat', ...
    'LineWidth', 1);

axis square;
xlim([0.5, numel(net_order) + 0.5]);
ylim([0.5, numel(net_order) + 0.5]);
set(gca, 'YDir', 'reverse', 'TickLength', [0 0], 'Box', 'on');

xticks(1:numel(net_order));
yticks(1:numel(net_order));

if show_axis_labels
    xticklabels(net_order);
    yticklabels(net_labels);
else
    xticklabels(repmat({''}, size(net_order)));
    yticklabels(repmat({''}, size(net_labels)));
end
xtickangle(45);

ax = gca;
ax.XAxis.FontWeight = 'normal';
ax.YAxis.FontWeight = 'normal';
ax.XAxis.FontSize = 12;
ax.YAxis.FontSize = 12;

colormap(make_edge_colormap(edge_sign));
clim([0, max_val]);

cb = colorbar;
cb.FontSize = 10;
cb.Label.String = '# of edges';
cb.Label.FontSize = 11;
cb.Label.Rotation = 90;
cb.Label.VerticalAlignment = 'bottom';

label_pos = cb.Label.Position;
label_pos(1) = label_pos(1) + 0.5;
cb.Label.Position = label_pos;

exportgraphics(gcf, output_file, 'Resolution', 300);
end

function cmap = make_edge_colormap(edge_sign)
n_colors = 256;

switch edge_sign
    case 'pos'
        low_rgb = [245, 245, 245] / 255;
        high_rgb = [255, 46, 99] / 255;
    case 'neg'
        low_rgb = [238, 238, 238] / 255;
        high_rgb = [23, 113, 191] / 255;
    otherwise
        error('edge_sign must be ''pos'' or ''neg''.');
end

cmap = [linspace(low_rgb(1), high_rgb(1), n_colors)', ...
    linspace(low_rgb(2), high_rgb(2), n_colors)', ...
    linspace(low_rgb(3), high_rgb(3), n_colors)'];
end
