%% Figure 4

%% Figure 4A

clear
close all

addpath('../model_analysis/simulation');
addpath('../model_analysis/OL/Model_RCImP4');

exclude_subj = [1 14 50 57 67 71 73 74 82 90 109 112];
total_subj = setdiff(1:136, exclude_subj);

COL_SELF_CHOICE = 4;
GROUP_BIAS_THRESHOLD = 1;
colors = [0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];

ingroup_sim = load('OL_simulated_all_final_Ingroup.mat', 'total_data');
total_data_In = ingroup_sim.total_data;
outgroup_sim = load('OL_simulated_all_final_Outgroup.mat', 'total_data');
total_data_Out = outgroup_sim.total_data;
simulation_info = load('OL_simulated_final_Info.mat', 'prob_A');
prob_A = simulation_info.prob_A;

model_parameter = load('OL_chain.mat', ...
    'medianPosteriorW1In', 'medianPosteriorW2In', ...
    'medianPosteriorW1Out', 'medianPosteriorW2Out');

GroupBias_Lose = model_parameter.medianPosteriorW2In - model_parameter.medianPosteriorW2Out;
lose_idx = find(GroupBias_Lose > GROUP_BIAS_THRESHOLD);

GroupBias_Win = model_parameter.medianPosteriorW1In - model_parameter.medianPosteriorW1Out;
win_idx = find(GroupBias_Win > GROUP_BIAS_THRESHOLD);

nTrials = size(total_data_In{1, 1}, 1);
nSubjects = numel(total_subj);
nIters = size(total_data_In, 2);
xvals = 1:nTrials;

all_self_choice_In = NaN(nSubjects, nTrials, nIters);
all_self_choice_Out = NaN(nSubjects, nTrials, nIters);

for iter = 1:nIters
    for subj = 1:nSubjects
        dIn = total_data_In{subj, iter};
        all_self_choice_In(subj, :, iter) = dIn(:, COL_SELF_CHOICE);

        dOut = total_data_Out{subj, iter};
        all_self_choice_Out(subj, :, iter) = dOut(:, COL_SELF_CHOICE);
    end
end

mean_per_subj_In = squeeze(mean(all_self_choice_In == 1, 3));
mean_per_subj_Out = squeeze(mean(all_self_choice_Out == 1, 3));

mean_choice_4A_In = mean(mean_per_subj_In, 1);
mean_choice_4A_Out = mean(mean_per_subj_Out, 1);

sem_choice_4A_In = std(mean_per_subj_In, 0, 1) / sqrt(nSubjects);
sem_choice_4A_Out = std(mean_per_subj_Out, 0, 1) / sqrt(nSubjects);

figure('Color', 'w', 'Position', [300 300 600 200]); hold on;
actual_handle = plot(xvals, prob_A, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 2);
fill([xvals, fliplr(xvals)], ...
     [mean_choice_4A_In + sem_choice_4A_In, fliplr(mean_choice_4A_In - sem_choice_4A_In)], ...
     colors(1,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
ingroup_handle = plot(xvals, mean_choice_4A_In, '-', 'Color', colors(1,:), 'LineWidth', 2);
fill([xvals, fliplr(xvals)], ...
     [mean_choice_4A_Out + sem_choice_4A_Out, fliplr(mean_choice_4A_Out - sem_choice_4A_Out)], ...
     colors(2,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
outgroup_handle = plot(xvals, mean_choice_4A_Out, '-', 'Color', colors(2,:), 'LineWidth', 2);

xlim([1 nTrials]);
ylim([0 1]);
set(gca, 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2);
legend([actual_handle, ingroup_handle, outgroup_handle], ...
    {'Actual', 'Ingroup', 'Outgroup'}, 'Location', 'northeast', 'FontSize', 8);

%% Figure 4B

fig4_data_ready = exist('mean_per_subj_In', 'var') && exist('mean_per_subj_Out', 'var') && ...
    exist('prob_A', 'var') && exist('win_idx', 'var') && exist('colors', 'var') && exist('xvals', 'var');

if ~fig4_data_ready
    addpath('../model_analysis/simulation');
    addpath('../model_analysis/OL/Model_RCImP4');

    exclude_subj = [1 14 50 57 67 71 73 74 82 90 109 112];
    total_subj = setdiff(1:136, exclude_subj);

    COL_SELF_CHOICE = 4;
    GROUP_BIAS_THRESHOLD = 1;
    colors = [0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];

    ingroup_sim = load('OL_simulated_all_final_Ingroup.mat', 'total_data');
    total_data_In = ingroup_sim.total_data;
    outgroup_sim = load('OL_simulated_all_final_Outgroup.mat', 'total_data');
    total_data_Out = outgroup_sim.total_data;
    simulation_info = load('OL_simulated_final_Info.mat', 'prob_A');
    prob_A = simulation_info.prob_A;

    model_parameter = load('OL_chain.mat', ...
        'medianPosteriorW1In', 'medianPosteriorW2In', ...
        'medianPosteriorW1Out', 'medianPosteriorW2Out');

    GroupBias_Lose = model_parameter.medianPosteriorW2In - model_parameter.medianPosteriorW2Out;
    lose_idx = find(GroupBias_Lose > GROUP_BIAS_THRESHOLD);

    GroupBias_Win = model_parameter.medianPosteriorW1In - model_parameter.medianPosteriorW1Out;
    win_idx = find(GroupBias_Win > GROUP_BIAS_THRESHOLD);

    nTrials = size(total_data_In{1, 1}, 1);
    nSubjects = numel(total_subj);
    nIters = size(total_data_In, 2);
    xvals = 1:nTrials;

    all_self_choice_In = NaN(nSubjects, nTrials, nIters);
    all_self_choice_Out = NaN(nSubjects, nTrials, nIters);

    for iter = 1:nIters
        for subj = 1:nSubjects
            dIn = total_data_In{subj, iter};
            all_self_choice_In(subj, :, iter) = dIn(:, COL_SELF_CHOICE);

            dOut = total_data_Out{subj, iter};
            all_self_choice_Out(subj, :, iter) = dOut(:, COL_SELF_CHOICE);
        end
    end

    mean_per_subj_In = squeeze(mean(all_self_choice_In == 1, 3));
    mean_per_subj_Out = squeeze(mean(all_self_choice_Out == 1, 3));
end

mean_choice_4B_In = mean(mean_per_subj_In(win_idx, :), 1);
mean_choice_4B_Out = mean(mean_per_subj_Out(win_idx, :), 1);

sem_choice_4B_In = std(mean_per_subj_In(win_idx, :), 0, 1) / sqrt(numel(win_idx));
sem_choice_4B_Out = std(mean_per_subj_Out(win_idx, :), 0, 1) / sqrt(numel(win_idx));

figure('Color', 'w', 'Position', [300 300 600 200]); hold on;
actual_handle = plot(xvals, prob_A, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 2);
fill([xvals, fliplr(xvals)], ...
     [mean_choice_4B_In + sem_choice_4B_In, fliplr(mean_choice_4B_In - sem_choice_4B_In)], ...
     colors(1,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
ingroup_handle = plot(xvals, mean_choice_4B_In, '-', 'Color', colors(1,:), 'LineWidth', 2);
fill([xvals, fliplr(xvals)], ...
     [mean_choice_4B_Out + sem_choice_4B_Out, fliplr(mean_choice_4B_Out - sem_choice_4B_Out)], ...
     colors(2,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
outgroup_handle = plot(xvals, mean_choice_4B_Out, '-', 'Color', colors(2,:), 'LineWidth', 2);

xlim([1 nTrials]);
ylim([0 1]);
set(gca, 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2);
legend([actual_handle, ingroup_handle, outgroup_handle], ...
    {'Actual', 'Ingroup', 'Outgroup'}, 'Location', 'northeast', 'FontSize', 8);

%% Figure 4C

fig4_data_ready = exist('mean_per_subj_In', 'var') && exist('mean_per_subj_Out', 'var') && ...
    exist('prob_A', 'var') && exist('lose_idx', 'var') && exist('colors', 'var') && exist('xvals', 'var');

if ~fig4_data_ready
    addpath('../model_analysis/simulation');
    addpath('../model_analysis/OL/Model_RCImP4');

    exclude_subj = [1 14 50 57 67 71 73 74 82 90 109 112];
    total_subj = setdiff(1:136, exclude_subj);

    COL_SELF_CHOICE = 4;
    GROUP_BIAS_THRESHOLD = 1;
    colors = [0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];

    ingroup_sim = load('OL_simulated_all_final_Ingroup.mat', 'total_data');
    total_data_In = ingroup_sim.total_data;
    outgroup_sim = load('OL_simulated_all_final_Outgroup.mat', 'total_data');
    total_data_Out = outgroup_sim.total_data;
    simulation_info = load('OL_simulated_final_Info.mat', 'prob_A');
    prob_A = simulation_info.prob_A;

    model_parameter = load('OL_chain.mat', ...
        'medianPosteriorW1In', 'medianPosteriorW2In', ...
        'medianPosteriorW1Out', 'medianPosteriorW2Out');

    GroupBias_Lose = model_parameter.medianPosteriorW2In - model_parameter.medianPosteriorW2Out;
    lose_idx = find(GroupBias_Lose > GROUP_BIAS_THRESHOLD);

    GroupBias_Win = model_parameter.medianPosteriorW1In - model_parameter.medianPosteriorW1Out;
    win_idx = find(GroupBias_Win > GROUP_BIAS_THRESHOLD);

    nTrials = size(total_data_In{1, 1}, 1);
    nSubjects = numel(total_subj);
    nIters = size(total_data_In, 2);
    xvals = 1:nTrials;

    all_self_choice_In = NaN(nSubjects, nTrials, nIters);
    all_self_choice_Out = NaN(nSubjects, nTrials, nIters);

    for iter = 1:nIters
        for subj = 1:nSubjects
            dIn = total_data_In{subj, iter};
            all_self_choice_In(subj, :, iter) = dIn(:, COL_SELF_CHOICE);

            dOut = total_data_Out{subj, iter};
            all_self_choice_Out(subj, :, iter) = dOut(:, COL_SELF_CHOICE);
        end
    end

    mean_per_subj_In = squeeze(mean(all_self_choice_In == 1, 3));
    mean_per_subj_Out = squeeze(mean(all_self_choice_Out == 1, 3));
end

mean_choice_4C_In = mean(mean_per_subj_In(lose_idx, :), 1);
mean_choice_4C_Out = mean(mean_per_subj_Out(lose_idx, :), 1);

sem_choice_4C_In = std(mean_per_subj_In(lose_idx, :), 0, 1) / sqrt(numel(lose_idx));
sem_choice_4C_Out = std(mean_per_subj_Out(lose_idx, :), 0, 1) / sqrt(numel(lose_idx));

figure('Color', 'w', 'Position', [300 300 600 200]); hold on;
actual_handle = plot(xvals, prob_A, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 2);
fill([xvals, fliplr(xvals)], ...
     [mean_choice_4C_In + sem_choice_4C_In, fliplr(mean_choice_4C_In - sem_choice_4C_In)], ...
     colors(1,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
ingroup_handle = plot(xvals, mean_choice_4C_In, '-', 'Color', colors(1,:), 'LineWidth', 2);
fill([xvals, fliplr(xvals)], ...
     [mean_choice_4C_Out + sem_choice_4C_Out, fliplr(mean_choice_4C_Out - sem_choice_4C_Out)], ...
     colors(2,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
outgroup_handle = plot(xvals, mean_choice_4C_Out, '-', 'Color', colors(2,:), 'LineWidth', 2);

xlim([1 nTrials]);
ylim([0 1]);
set(gca, 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2);
legend([actual_handle, ingroup_handle, outgroup_handle], ...
    {'Actual', 'Ingroup', 'Outgroup'}, 'Location', 'northeast', 'FontSize', 8);
