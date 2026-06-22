%% Model simulation for Figure 4

clear
close all

addpath('../OL/Model_RCImP4');

rng_seed = 2024;
n_trials = 500;
n_iters = 100;
n_all_subjects = 136;
exclude_subj = [1 14 50 57 67 71 73 74 82 90 109 112];
total_subj = setdiff(1:n_all_subjects, exclude_subj);
random_walk_sigma = 0.05;

rng(rng_seed, 'twister');

[prob_A, prob_B] = generate_random_walk(n_trials, random_walk_sigma);

simulation_settings = struct();
simulation_settings.rng_seed = rng_seed;
simulation_settings.n_trials = n_trials;
simulation_settings.n_iters = n_iters;
simulation_settings.n_all_subjects = n_all_subjects;
simulation_settings.exclude_subj = exclude_subj;
simulation_settings.total_subj = total_subj;
simulation_settings.random_walk_sigma = random_walk_sigma;
simulation_settings.output_columns = struct( ...
    'partner_choice', 1, ...
    'partner_reward', 2, ...
    'prediction_choice', 3, ...
    'self_choice', 4);

save('OL_simulated_final_Info.mat', 'prob_A', 'prob_B', 'simulation_settings');

model_parameter = load('OL_chain.mat', ...
    'medianPosteriorLr', 'medianPosteriorK', ...
    'medianPosteriorW1In', 'medianPosteriorW2In', ...
    'medianPosteriorW1Out', 'medianPosteriorW2Out', ...
    'medianPosteriorInvTemp');

parameters = struct();
parameters.learning_rate = model_parameter.medianPosteriorLr(:);
parameters.action_learning_rate = model_parameter.medianPosteriorK(:);
parameters.inverse_temperature = model_parameter.medianPosteriorInvTemp(:);

n_subjects = numel(total_subj);
parameter_lengths = [ ...
    numel(parameters.learning_rate), ...
    numel(parameters.action_learning_rate), ...
    numel(parameters.inverse_temperature), ...
    numel(model_parameter.medianPosteriorW1In), ...
    numel(model_parameter.medianPosteriorW2In), ...
    numel(model_parameter.medianPosteriorW1Out), ...
    numel(model_parameter.medianPosteriorW2Out)];

if any(parameter_lengths ~= n_subjects)
    error('Model_simulation_final:ParameterSizeMismatch', ...
        'Expected %d subject-level parameters, but found [%s].', ...
        n_subjects, num2str(parameter_lengths));
end

group_config = struct( ...
    'name', {'Ingroup', 'Outgroup'}, ...
    'win_bias', {model_parameter.medianPosteriorW1In(:), model_parameter.medianPosteriorW1Out(:)}, ...
    'lose_bias', {model_parameter.medianPosteriorW2In(:), model_parameter.medianPosteriorW2Out(:)}, ...
    'output_file', {'OL_simulated_all_final_Ingroup.mat', 'OL_simulated_all_final_Outgroup.mat'});

for group_idx = 1:numel(group_config)
    [total_data, simulation_qc] = simulate_group( ...
        prob_A, prob_B, parameters, ...
        group_config(group_idx).win_bias, ...
        group_config(group_idx).lose_bias, ...
        n_iters);

    group_settings = simulation_settings;
    group_settings.group = group_config(group_idx).name;

    save(group_config(group_idx).output_file, 'total_data', 'group_settings', 'simulation_qc');
end

function [prob_A, prob_B] = generate_random_walk(n_trials, sigma)
    prob_A = NaN(n_trials, 1);
    prob_A(1) = 0.5;

    for trial = 2:n_trials
        prob_A(trial) = prob_A(trial - 1) + randn * sigma;
        prob_A(trial) = min(max(prob_A(trial), 0.2), 0.8);
    end

    prob_B = 1 - prob_A;
end

function [total_data, simulation_qc] = simulate_group(prob_A, prob_B, parameters, win_bias, lose_bias, n_iters)
    n_subjects = numel(parameters.learning_rate);
    n_trials = numel(prob_A);

    total_data = cell(n_subjects, n_iters);
    self_accuracy = NaN(n_subjects, n_iters);
    high_prob_choice = double(prob_A > prob_B);

    for iter = 1:n_iters
        partner_choice = randi([0, 1], n_subjects, n_trials);
        reward_prob = partner_choice .* prob_A' + (1 - partner_choice) .* prob_B';
        partner_reward = double(rand(n_subjects, n_trials) <= reward_prob);

        prediction_choice = NaN(n_subjects, n_trials);
        self_choice = NaN(n_subjects, n_trials);

        for subj = 1:n_subjects
            [prediction_choice(subj, :), self_choice(subj, :)] = simulate_subject( ...
                partner_choice(subj, :), ...
                partner_reward(subj, :), ...
                parameters.learning_rate(subj), ...
                parameters.action_learning_rate(subj), ...
                parameters.inverse_temperature(subj), ...
                win_bias(subj), ...
                lose_bias(subj));

            total_data{subj, iter} = [ ...
                partner_choice(subj, :)', ...
                partner_reward(subj, :)', ...
                prediction_choice(subj, :)', ...
                self_choice(subj, :)'];

            self_accuracy(subj, iter) = mean(self_choice(subj, :)' == high_prob_choice);
        end
    end

    self_accuracy_by_subject = mean(self_accuracy, 2);

    simulation_qc = struct();
    simulation_qc.self_accuracy_by_subject = self_accuracy_by_subject;
    simulation_qc.self_accuracy_mean = mean(self_accuracy_by_subject);
    simulation_qc.self_accuracy_sem = std(self_accuracy_by_subject, 0) / sqrt(n_subjects);
end

function [prediction_choice, self_choice] = simulate_subject( ...
    partner_choice, partner_reward, learning_rate, action_learning_rate, ...
    inverse_temperature, win_bias, lose_bias)

    n_trials = numel(partner_choice);

    prediction_choice = NaN(1, n_trials);
    q_a_history = NaN(1, n_trials);
    q_b_history = NaN(1, n_trials);

    q_a = 0.5;
    q_b = 0.5;

    for trial = 1:n_trials
        if trial == 1
            pred_prob_a = 0.5;
        else
            pred_prob_a = logistic(inverse_temperature * (q_a - q_b));
        end

        prediction_choice(trial) = double(rand <= pred_prob_a);
        partner_bias = get_prediction_bias( ...
            prediction_choice(trial), partner_choice(trial), partner_reward(trial), ...
            win_bias, lose_bias);

        if partner_choice(trial) == 1
            q_a = q_a + learning_rate * (partner_reward(trial) - q_a) + ...
                action_learning_rate * (1 - pred_prob_a) + partner_bias;
        else
            pred_prob_b = 1 - pred_prob_a;
            q_b = q_b + learning_rate * (partner_reward(trial) - q_b) + ...
                action_learning_rate * (1 - pred_prob_b) + partner_bias;
        end

        q_a_history(trial) = q_a;
        q_b_history(trial) = q_b;
    end

    self_choice_prob = logistic(inverse_temperature * (q_a_history - q_b_history));
    self_choice = double(rand(1, n_trials) <= self_choice_prob);
end

function partner_bias = get_prediction_bias(prediction_choice, partner_choice, partner_reward, win_bias, lose_bias)
    if prediction_choice == partner_choice && partner_reward == 1
        partner_bias = win_bias;
    elseif prediction_choice ~= partner_choice && partner_reward == 0
        partner_bias = lose_bias;
    else
        partner_bias = 0;
    end
end

function probability = logistic(value)
    probability = 1 ./ (1 + exp(-value));
end
