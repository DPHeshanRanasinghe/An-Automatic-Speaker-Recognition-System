%% SPEAKER RECOGNITION SYSTEM
% This script demonstrates a complete speaker recognition system using
% MFCC features extracted from scratch.
%
% WORKFLOW:
%   1. Build speaker database from training audio
%   2. Test recognition on test audio files
%   3. Display results and confusion matrix
%   4. Compare different distance metrics
%
% FOLDER STRUCTURE:
%   data/train/  - Training audio files (s1.wav, s2.wav, ...)
%   data/test/   - Testing audio files (s1.wav, s2.wav, ...)

clc;
clear;
close all;

%% Configuration
TRAIN_FOLDER = 'data/train';
TEST_FOLDER = 'data/test';
DATABASE_FILE = 'speaker_database.mat';

% Check if folders exist
if ~exist(TRAIN_FOLDER, 'dir')
    error('Training folder not found: %s', TRAIN_FOLDER);
end
if ~exist(TEST_FOLDER, 'dir')
    error('Testing folder not found: %s', TEST_FOLDER);
end

%% Step 1: Build Speaker Database
fprintf('==============================================\n');
fprintf('STEP 1: BUILDING SPEAKER DATABASE\n');
fprintf('==============================================\n');

% Build database from training data
speaker_database = build_speaker_database(TRAIN_FOLDER);

% Save database for future use
save(DATABASE_FILE, 'speaker_database');
fprintf('Database saved to: %s\n\n', DATABASE_FILE);

%% Step 2: Test Speaker Recognition

% Test with different distance metrics
distance_metrics = {'euclidean', 'cosine', 'mahalanobis'};
all_results = cell(length(distance_metrics), 1);

fprintf('==============================================\n');
fprintf('STEP 2: TESTING SPEAKER RECOGNITION\n');
fprintf('==============================================\n\n');

for i = 1:length(distance_metrics)
    metric = distance_metrics{i};
    fprintf('\n>>> Testing with %s distance <<<\n', upper(metric));
    all_results{i} = test_speaker_recognition(speaker_database, TEST_FOLDER, metric);
end

%% Step 3: Display Results and Analysis

fprintf('\n==============================================\n');
fprintf('STEP 3: RESULTS ANALYSIS\n');
fprintf('==============================================\n\n');

% Compare accuracy of different metrics
fprintf('Accuracy Comparison:\n');
fprintf('%-15s | Accuracy\n', 'Metric');
fprintf('%-15s-+---------\n', '---------------');
for i = 1:length(distance_metrics)
    accuracy = sum([all_results{i}.correct]) / length(all_results{i}) * 100;
    fprintf('%-15s | %.2f%%\n', upper(distance_metrics{i}), accuracy);
end
fprintf('\n');

% Use the first metric (Euclidean) for detailed analysis
results = all_results{1};

% Create confusion matrix
speaker_ids = {speaker_database.speaker_id};
num_speakers = length(speaker_ids);
confusion_mat = zeros(num_speakers, num_speakers);

for i = 1:length(results)
    true_idx = find(strcmp(speaker_ids, results(i).true_speaker));
    pred_idx = find(strcmp(speaker_ids, results(i).predicted_speaker));
    if ~isempty(true_idx) && ~isempty(pred_idx)
        confusion_mat(true_idx, pred_idx) = confusion_mat(true_idx, pred_idx) + 1;
    end
end

% Display confusion matrix
fprintf('Confusion Matrix (Euclidean Distance):\n');
fprintf('Rows: True Speaker, Columns: Predicted Speaker\n\n');
fprintf('%8s', ' ');
for i = 1:num_speakers
    fprintf('%8s', speaker_ids{i});
end
fprintf('\n');
for i = 1:num_speakers
    fprintf('%8s', speaker_ids{i});
    for j = 1:num_speakers
        fprintf('%8d', confusion_mat(i, j));
    end
    fprintf('\n');
end
fprintf('\n');

%% Step 4: Visualization

% Plot confusion matrix
figure('Name', 'Confusion Matrix', 'NumberTitle', 'off');
imagesc(confusion_mat);
colorbar;
colormap('hot');
title('Speaker Recognition Confusion Matrix (Euclidean)');
xlabel('Predicted Speaker');
ylabel('True Speaker');
set(gca, 'XTick', 1:num_speakers, 'XTickLabel', speaker_ids);
set(gca, 'YTick', 1:num_speakers, 'YTickLabel', speaker_ids);

% Add text annotations
for i = 1:num_speakers
    for j = 1:num_speakers
        text(j, i, num2str(confusion_mat(i, j)), ...
             'HorizontalAlignment', 'center', ...
             'Color', 'white', 'FontWeight', 'bold');
    end
end

% Plot accuracy comparison
figure('Name', 'Accuracy Comparison', 'NumberTitle', 'off');
accuracies = zeros(length(distance_metrics), 1);
for i = 1:length(distance_metrics)
    accuracies(i) = sum([all_results{i}.correct]) / length(all_results{i}) * 100;
end
bar(accuracies);
set(gca, 'XTickLabel', distance_metrics);
ylabel('Accuracy (%)');
title('Speaker Recognition Accuracy by Distance Metric');
ylim([0 100]);
grid on;

% Add value labels on bars
for i = 1:length(accuracies)
    text(i, accuracies(i) + 2, sprintf('%.2f%%', accuracies(i)), ...
         'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end

% Plot confidence distribution
figure('Name', 'Confidence Distribution', 'NumberTitle', 'off');
confidences = [results.confidence] * 100;
correct_conf = confidences([results.correct]);
incorrect_conf = confidences(~[results.correct]);

hold on;
if ~isempty(correct_conf)
    histogram(correct_conf, 'FaceColor', 'g', 'EdgeColor', 'k', 'FaceAlpha', 0.7);
end
if ~isempty(incorrect_conf)
    histogram(incorrect_conf, 'FaceColor', 'r', 'EdgeColor', 'k', 'FaceAlpha', 0.7);
end
hold off;

xlabel('Confidence (%)');
ylabel('Frequency');
title('Prediction Confidence Distribution');
legend('Correct', 'Incorrect');
grid on;

fprintf('\n==============================================\n');
fprintf('ANALYSIS COMPLETE!\n');
fprintf('==============================================\n\n');
fprintf('Check the generated plots for visual analysis.\n');
fprintf('Database is saved in: %s\n', DATABASE_FILE);
fprintf('\nYou can now use the database for new predictions:\n');
fprintf('  load(''%s'');\n', DATABASE_FILE);
fprintf('  results = test_speaker_recognition(speaker_database, ''path/to/new/audio'');\n');
