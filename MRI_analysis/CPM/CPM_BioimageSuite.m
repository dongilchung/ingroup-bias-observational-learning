% Create thresholded edge matrices for BioImage Suite Web.
% Run after CPM_covariates.m.

required_vars = {'edge_count_pos', 'edge_count_neg', 'no_node', 'no_sub'};
for var_idx = 1:numel(required_vars)
    if ~exist(required_vars{var_idx}, 'var')
        error('CPM_BioimageSuite:MissingVariable', ...
            'Run CPM_covariates.m before CPM_BioimageSuite.m. Missing variable: %s', ...
            required_vars{var_idx});
    end
end

threshold_ratio = 1;
threshold_value = round(threshold_ratio * no_sub);

pos_mask = edge_count_pos >= threshold_value;
pos_mask = pos_mask & ~eye(no_node);
thresholded_pos_binary = double(pos_mask | pos_mask');

neg_mask = edge_count_neg >= threshold_value;
neg_mask = neg_mask & ~eye(no_node);
thresholded_neg_binary = double(neg_mask | neg_mask');

if exist('condition_name', 'var')
    condition_suffix = ['_' lower(char(string(condition_name)))];
else
    condition_suffix = '';
end

pos_output_file = ['connectivity_threshold_pos_binary' condition_suffix '.csv'];
neg_output_file = ['connectivity_threshold_neg_binary' condition_suffix '.csv'];

writematrix(thresholded_pos_binary, pos_output_file);
writematrix(thresholded_neg_binary, neg_output_file);

fprintf('Saved %s\n', pos_output_file);
fprintf('Saved %s\n', neg_output_file);
