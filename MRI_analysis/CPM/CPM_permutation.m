function result = CPM_permutation(condition_name, edge_sign, behavior_name, output_file, varargin)
% Run CPM permutation testing for one condition, edge sign, and behavior.

condition_name = char(string(condition_name));
edge_sign = lower(char(string(edge_sign)));
behavior_name = char(string(behavior_name));
output_file = char(string(output_file));

parser = inputParser;
addParameter(parser, 'n_perm', 5000, @(x) isnumeric(x) && isscalar(x) && x >= 1);
addParameter(parser, 'thresh', 0.01, @(x) isnumeric(x) && isscalar(x) && x > 0);
addParameter(parser, 'r_threshold', 0.2, @(x) isnumeric(x) && isscalar(x) && x >= 0);
addParameter(parser, 'random_seed', 'shuffle');
parse(parser, varargin{:});

n_perm = parser.Results.n_perm;
thresh = parser.Results.thresh;
r_threshold = parser.Results.r_threshold;
random_seed = parser.Results.random_seed;

if ~ismember(edge_sign, {'pos', 'neg'})
    error('edge_sign must be ''pos'' or ''neg''.');
end

cpm_dir = fileparts(mfilename('fullpath'));
fc_file = fullfile(cpm_dir, sprintf('resultsROI_Condition%s.mat', condition_name));
behavior_file = fullfile(cpm_dir, 'Conn_ID.csv');
output_path = resolve_output_path(cpm_dir, output_file);

fc_data = load(fc_file, 'Z');
all_mats = fc_data.Z;
behavior_table = readtable(behavior_file);

if ~ismember(behavior_name, behavior_table.Properties.VariableNames)
    error('Behavior variable ''%s'' was not found in Conn_ID.csv.', behavior_name);
end

[all_mats, all_behav] = prepare_behavior_and_mats(all_mats, behavior_table, behavior_name);

fprintf('CPM permutation: %s, %s edges, %s\n', condition_name, edge_sign, behavior_name);
[behav_pred, edge_count] = run_cpm_predictions(all_mats, all_behav, edge_sign, thresh, r_threshold, true);

valid_idx = ~isnan(behav_pred);
r_true = corr(behav_pred(valid_idx), all_behav(valid_idx), 'Type', 'Spearman');
fprintf('CPM prediction result (Spearman): r = %.3f\n', r_true);

set_random_seed(random_seed, 0);
worker_count = select_worker_count(n_perm);
perm_per_worker = n_perm / worker_count;
r_null_parts = cell(worker_count, 1);

if worker_count == 1
    r_null_parts{1} = run_permutation_chunk(all_mats, all_behav, edge_sign, thresh, r_threshold, perm_per_worker);
else
    pool = prepare_parallel_pool(worker_count);
    cleanup_pool = onCleanup(@() close_pool_if_started(pool.started));

    parfor worker_idx = 1:worker_count
        set_random_seed(random_seed, worker_idx);
        fprintf('Worker %d started (perms %d-%d)\n', ...
            worker_idx, (worker_idx - 1) * perm_per_worker + 1, worker_idx * perm_per_worker);
        r_null_parts{worker_idx} = run_permutation_chunk( ...
            all_mats, all_behav, edge_sign, thresh, r_threshold, perm_per_worker);
    end
end

r_null = vertcat(r_null_parts{:});

if r_true >= 0
    p_value = mean(r_null >= r_true);
else
    p_value = mean(r_null <= r_true);
end

fprintf('Permutation test result: r_true = %.3f, p = %.4f\n', r_true, p_value);

save(output_path, 'r_null_parts', 'r_true', 'r_null', 'p_value');
plot_permutation_result(r_null, r_true, p_value);

result = struct();
result.condition_name = condition_name;
result.edge_sign = edge_sign;
result.behavior_name = behavior_name;
result.output_file = output_path;
result.r_true = r_true;
result.p_value = p_value;
result.r_null = r_null;
result.edge_count = edge_count;
end

function worker_count = select_worker_count(n_perm)
candidate_counts = [10, 5, 4, 2, 1];
worker_count = candidate_counts(find(mod(n_perm, candidate_counts) == 0, 1));
end

function [all_mats, all_behav] = prepare_behavior_and_mats(all_mats, behavior_table, behavior_name)
all_behav = behavior_table.(behavior_name);
all_behav = all_behav(:);

pol_orient = behavior_table.PolOrient;
age = behavior_table.Age;
gender = behavior_table.Gender;
education = behavior_table.Education;

nan_idx = isnan(all_behav);
all_behav(nan_idx) = [];
all_mats(:, :, nan_idx) = [];
pol_orient(nan_idx) = [];
age(nan_idx) = [];
gender(nan_idx) = [];
education(nan_idx) = [];

X_cov = [zscore(pol_orient), zscore(age), gender, zscore(education), ones(length(all_behav), 1)];
b_cov = regress(all_behav, X_cov);
all_behav = all_behav - X_cov * b_cov;

nan_idx = isnan(all_behav);
all_behav(nan_idx) = [];
all_mats(:, :, nan_idx) = [];
end

function [behav_pred, edge_count] = run_cpm_predictions(all_mats, all_behav, edge_sign, thresh, r_threshold, verbose)
no_sub = size(all_mats, 3);
no_node = size(all_mats, 1);
behav_pred = NaN(no_sub, 1);
edge_count = zeros(no_node, no_node);

for leftout = 1:no_sub
    if verbose
        fprintf('Leaving out subj %d/%d...\n', leftout, no_sub);
    end

    train_mats = all_mats;
    train_mats(:, :, leftout) = [];
    train_behav = all_behav;
    train_behav(leftout) = [];

    train_vcts = reshape(train_mats, [], no_sub - 1);
    [r_mat, p_mat] = corr(train_vcts', train_behav, 'type', 'Spearman');
    r_mat = reshape(r_mat, no_node, no_node);
    p_mat = reshape(p_mat, no_node, no_node);

    edge_mask = select_edge_mask(r_mat, p_mat, edge_sign, thresh, r_threshold);

    if nnz(edge_mask) == 0
        if verbose
            warning('No predictive edges selected for subject %d. Skipping...', leftout);
        end
        continue;
    end

    edge_count = edge_count + edge_mask;
    train_sum = get_edge_strength(train_mats, edge_mask);
    X = [train_sum, ones(no_sub - 1, 1)];
    b = regress(train_behav, X);

    test_mat = all_mats(:, :, leftout);
    test_sum = sum(test_mat(edge_mask), 'all') / 2;
    behav_pred(leftout) = b(1) * test_sum + b(2);
end
end

function r_null = run_permutation_chunk(all_mats, all_behav, edge_sign, thresh, r_threshold, n_perm)
no_sub = size(all_mats, 3);
r_null = zeros(n_perm, 1);

for perm_idx = 1:n_perm
    shuffled_behav = all_behav(randperm(no_sub));
    behav_pred_perm = run_cpm_predictions(all_mats, shuffled_behav, edge_sign, thresh, r_threshold, false);
    valid_perm = ~isnan(behav_pred_perm);
    r_null(perm_idx) = corr(behav_pred_perm(valid_perm), shuffled_behav(valid_perm), 'Type', 'Spearman');
end
end

function edge_mask = select_edge_mask(r_mat, p_mat, edge_sign, thresh, r_threshold)
switch edge_sign
    case 'pos'
        edge_mask = (r_mat > r_threshold) & (p_mat < thresh);
    case 'neg'
        edge_mask = (r_mat < -r_threshold) & (p_mat < thresh);
end
end

function edge_strength = get_edge_strength(mats, edge_mask)
no_sub = size(mats, 3);
edge_strength = zeros(no_sub, 1);

for subj_idx = 1:no_sub
    mat = mats(:, :, subj_idx);
    edge_strength(subj_idx) = sum(mat(edge_mask), 'all') / 2;
end
end

function set_random_seed(random_seed, worker_idx)
if ischar(random_seed) || isstring(random_seed)
    if strcmpi(char(random_seed), 'shuffle')
        rng('shuffle');
    else
        rng(str2double(random_seed) + worker_idx);
    end
else
    rng(random_seed + worker_idx);
end
end

function pool_state = prepare_parallel_pool(worker_count)
pool_state.started = false;
pool = gcp('nocreate');

if isempty(pool)
    parpool(worker_count);
    pool_state.started = true;
elseif pool.NumWorkers ~= worker_count
    delete(pool);
    parpool(worker_count);
    pool_state.started = true;
end
end

function close_pool_if_started(started_pool)
if started_pool
    delete(gcp('nocreate'));
end
end

function output_path = resolve_output_path(base_dir, output_file)
if is_absolute_path(output_file)
    output_path = output_file;
else
    output_path = fullfile(base_dir, output_file);
end

[output_dir, ~, ~] = fileparts(output_path);
if ~isempty(output_dir) && ~isfolder(output_dir)
    mkdir(output_dir);
end
end

function tf = is_absolute_path(path_name)
tf = startsWith(path_name, filesep) || ~isempty(regexp(path_name, '^[A-Za-z]:[\\/]', 'once'));
end

function plot_permutation_result(r_null, r_true, p_value)
figure;
histogram(r_null, 30, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'k');
hold on;
x_min = min([r_null; r_true]) - 0.05;
x_max = max([r_null; r_true]) + 0.05;
xlim([x_min x_max]);
yl = ylim;
plot([r_true r_true], yl, 'r', 'LineWidth', 2);
text(r_true + 0.01, yl(2) * 0.9, sprintf('r_{true} = %.3f\np = %.4f', r_true, p_value), ...
    'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
xlabel('Spearman r (null distribution)');
ylabel('Frequency');
title(sprintf('Permutation test (p = %.4f)', p_value));
grid on;
end
