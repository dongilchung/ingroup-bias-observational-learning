%% Figure S8

clear
close all

exclude_subj = [1 14 50 57 67 71 73 74 82 90 109 112];
total_subj = setdiff(1:136, exclude_subj);

model_parameter = load('../model_analysis/OL/Model_RCImP4/OL_chain.mat', ...
    'medianPosteriorW1In', 'medianPosteriorW2In', ...
    'medianPosteriorW1Out', 'medianPosteriorW2Out');

behavior_data = load('../behavior_data/OL/pred_WSLS_InOut.mat', ...
    'pred_WS_In', 'nopred_WS_In', ...
    'pred_WS_Out', 'nopred_WS_Out', ...
    'pred_LS_In', 'nopred_LS_In', ...
    'pred_LS_Out', 'nopred_LS_Out');

pred_WS_In = behavior_data.pred_WS_In(total_subj,:);
nopred_WS_In = behavior_data.nopred_WS_In(total_subj,:);
pred_WS_Out = behavior_data.pred_WS_Out(total_subj,:);
nopred_WS_Out = behavior_data.nopred_WS_Out(total_subj,:);
pred_LS_In = behavior_data.pred_LS_In(total_subj,:);
nopred_LS_In = behavior_data.nopred_LS_In(total_subj,:);
pred_LS_Out = behavior_data.pred_LS_Out(total_subj,:);
nopred_LS_Out = behavior_data.nopred_LS_Out(total_subj,:);

model_values = [ ...
    model_parameter.medianPosteriorW1In, ...
    model_parameter.medianPosteriorW1Out, ...
    model_parameter.medianPosteriorW2In, ...
    model_parameter.medianPosteriorW2Out];

behavior_diff = [ ...
    pred_WS_In - nopred_WS_In, ...
    pred_WS_Out - nopred_WS_Out, ...
    nopred_LS_In - pred_LS_In, ...
    nopred_LS_Out - pred_LS_Out];

comparison_names = {'win_ingroup', 'win_outgroup', 'lose_ingroup', 'lose_outgroup'};

stats_FigureS8 = struct();
for i = 1:numel(comparison_names)
    [r_value, p_value, fit_object] = plot_prediction_bias_correlation(model_values(:,i), behavior_diff(:,i));

    stats_FigureS8.(comparison_names{i}) = struct();
    stats_FigureS8.(comparison_names{i}).r = r_value;
    stats_FigureS8.(comparison_names{i}).p = p_value;
    stats_FigureS8.(comparison_names{i}).fit = fit_object;
end

function [r_value, p_value, fit_object] = plot_prediction_bias_correlation(model_value, behavior_value)
    [r_value, p_value] = corr(model_value, behavior_value, 'rows', 'complete');

    figure('color', 'w', 'Position', [500, 500, 280, 240]);
    scatter(model_value, behavior_value, 100, 'k', 'filled');
    set(gca, 'FontSize', 18, 'LineWidth', 2);
    xticks([-1 -0.5 0 0.5 1]);
    hold on;

    valid_idx = ~isnan(model_value) & ~isnan(behavior_value);
    fit_object = fit(model_value(valid_idx), behavior_value(valid_idx), 'poly1');
    h = plot(fit_object, 'r');
    set(h, 'LineWidth', 4);

    legend off;
    hold off;
    xlabel('', 'FontSize', 12);
    ylabel('', 'FontSize', 12);
end
