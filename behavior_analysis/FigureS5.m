%% Figure S5

clear
close all

political_groups = load('../behavior_data/PoliticalGroups.mat', 'Centrism', 'Conservatism', 'Progressivism');

Pro_ID = political_groups.Progressivism(:,1);
Cen_ID = political_groups.Centrism(:,1);
Con_ID = political_groups.Conservatism(:,1);
group_ids = {Pro_ID, Cen_ID, Con_ID};

prediction_wsls = load('../behavior_data/OL/Prediction_WSLS_InOut.mat', ...
    'pred_WS_In', 'pred_WS_Out', ...
    'nopred_WS_In', 'nopred_WS_Out', ...
    'pred_LS_In', 'pred_LS_Out', ...
    'nopred_LS_In', 'nopred_LS_Out');

stats_FigureS5 = struct();

stats_FigureS5.pred_WS = plot_prediction_group_difference( ...
    prediction_wsls.pred_WS_In, prediction_wsls.pred_WS_Out, group_ids, false, false);

stats_FigureS5.nopred_WS = plot_prediction_group_difference( ...
    prediction_wsls.nopred_WS_In, prediction_wsls.nopred_WS_Out, group_ids, true, false);

stats_FigureS5.pred_LS = plot_prediction_group_difference( ...
    prediction_wsls.pred_LS_In, prediction_wsls.pred_LS_Out, group_ids, false, false);

stats_FigureS5.nopred_LS = plot_prediction_group_difference( ...
    prediction_wsls.nopred_LS_In, prediction_wsls.nopred_LS_Out, group_ids, true, true);

function stats_out = plot_prediction_group_difference(in_values, out_values, group_ids, omit_nan, run_pairwise_tests)
    Pro = in_values(group_ids{1},:) - out_values(group_ids{1},:);
    Cen = in_values(group_ids{2},:) - out_values(group_ids{2},:);
    Con = in_values(group_ids{3},:) - out_values(group_ids{3},:);

    if omit_nan
        mean_Pro = mean(Pro, 'omitnan');
        mean_Cen = mean(Cen, 'omitnan');
        mean_Con = mean(Con, 'omitnan');
        sem_Pro = std(Pro, 0, 'omitnan') / sqrt(nnz(~isnan(Pro)));
        sem_Cen = std(Cen, 0, 'omitnan') / sqrt(nnz(~isnan(Cen)));
        sem_Con = std(Con, 0, 'omitnan') / sqrt(nnz(~isnan(Con)));
    else
        mean_Pro = mean(Pro);
        mean_Cen = mean(Cen);
        mean_Con = mean(Con);
        sem_Pro = std(Pro) / sqrt(numel(Pro));
        sem_Cen = std(Cen) / sqrt(numel(Cen));
        sem_Con = std(Con) / sqrt(numel(Con));
    end

    barData = [mean_Pro, mean_Cen, mean_Con];
    sem_barData = [sem_Pro, sem_Cen, sem_Con];

    figure('color', 'w', 'Position', [500, 500, 280, 240]);
    bar(1:3, barData, 'FaceColor', 'flat', 'CData', [0 0 1; 0 0 0; 1 0 0], ...
        'FaceAlpha', 0.5, 'EdgeColor', 'none');
    hold on;
    scatter(ones(size(Pro)) + 0.3*rand(size(Pro)) - 0.15, Pro, 40, 'b', 'filled');
    scatter(2*ones(size(Cen)) + 0.3*rand(size(Cen)) - 0.15, Cen, 40, 'k', 'filled');
    scatter(3*ones(size(Con)) + 0.3*rand(size(Con)) - 0.15, Con, 40, 'r', 'filled');

    err = errorbar(1:3, barData, sem_barData, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'b');
    err.CapSize = 15;
    err = errorbar(2, mean_Cen, sem_Cen, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'k');
    err.CapSize = 15;
    err = errorbar(3, mean_Con, sem_Con, 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'r');
    err.CapSize = 15;

    set(gca, 'XTick', 1:3, 'XTickLabel', {'', '', ''}, 'FontSize', 16);
    ylim([-1 1]);
    set(gca, 'YTick', [-1 -0.5 0 0.5 1]);
    set(gca, 'LineWidth', 2);

    hold off;

    [h_pro, p_pro, ci_pro, ttest_stats_pro] = ttest(Pro);
    [h_cen, p_cen, ci_cen, ttest_stats_cen] = ttest(Cen);
    [h_con, p_con, ci_con, ttest_stats_con] = ttest(Con);

    stats_out = struct();
    stats_out.bar_data = barData;
    stats_out.sem = sem_barData;
    stats_out.pro_vs_zero = struct('h', h_pro, 'p', p_pro, 'ci', ci_pro, 'stats', ttest_stats_pro);
    stats_out.cen_vs_zero = struct('h', h_cen, 'p', p_cen, 'ci', ci_cen, 'stats', ttest_stats_cen);
    stats_out.con_vs_zero = struct('h', h_con, 'p', p_con, 'ci', ci_con, 'stats', ttest_stats_con);

    if run_pairwise_tests
        [h_pro_cen, p_pro_cen, ci_pro_cen, ttest_stats_pro_cen] = ttest2(Pro, Cen);
        [h_pro_con, p_pro_con, ci_pro_con, ttest_stats_pro_con] = ttest2(Pro, Con);
        [h_cen_con, p_cen_con, ci_cen_con, ttest_stats_cen_con] = ttest2(Cen, Con);

        stats_out.pairwise = struct();
        stats_out.pairwise.pro_vs_cen = struct('h', h_pro_cen, 'p', p_pro_cen, 'ci', ci_pro_cen, 'stats', ttest_stats_pro_cen);
        stats_out.pairwise.pro_vs_con = struct('h', h_pro_con, 'p', p_pro_con, 'ci', ci_pro_con, 'stats', ttest_stats_pro_con);
        stats_out.pairwise.cen_vs_con = struct('h', h_cen_con, 'p', p_cen_con, 'ci', ci_cen_con, 'stats', ttest_stats_cen_con);
    end
end
