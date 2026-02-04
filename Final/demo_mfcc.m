% DEMO_MFCC - Demonstration of MFCC feature extraction with visualization
%
% This script demonstrates the complete MFCC pipeline on a sample audio file
% and shows all visualizations.

clear; clc; close all;

% Change to the script's directory and add to path
script_dir = fileparts(mfilename('fullpath'));
cd(script_dir);
addpath(script_dir);

fprintf('\n');
fprintf('========================================\n');
fprintf('     MFCC FEATURE EXTRACTION DEMO\n');
fprintf('========================================\n\n');
fprintf('Working directory: %s\n\n', pwd);

% =========================================================================
% Find a sample audio file
% =========================================================================
fprintf('Looking for audio files...\n');

% Try to find any .wav file in data folders
sample_file = '';

if exist('data/train', 'dir')
    train_files = dir('data/train/*.wav');
    if ~isempty(train_files)
        sample_file = fullfile('data/train', train_files(1).name);
    end
end

if isempty(sample_file) && exist('data/test', 'dir')
    test_files = dir('data/test/*.wav');
    if ~isempty(test_files)
        sample_file = fullfile('data/test', test_files(1).name);
    end
end

if isempty(sample_file)
    error(['No audio files found in data/train or data/test folders!\n' ...
           'Please add .wav files to these directories.']);
end

fprintf('Using sample file: %s\n\n', sample_file);

% =========================================================================
% Extract features with visualization
% =========================================================================
fprintf('Extracting 39-dimensional MFCC features...\n\n');

[features, mfcc_coeffs, delta, delta2] = mfcc(sample_file, true);

% =========================================================================
% Display statistics
% =========================================================================
fprintf('\n========================================\n');
fprintf('     FEATURE STATISTICS\n');
fprintf('========================================\n\n');

fprintf('Feature dimensions: %d frames × %d features\n', size(features));
fprintf('\nFeature ranges:\n');
fprintf('  MFCC:         [%.2f, %.2f]\n', min(mfcc_coeffs(:)), max(mfcc_coeffs(:)));
fprintf('  Delta:        [%.2f, %.2f]\n', min(delta(:)), max(delta(:)));
fprintf('  Delta-Delta:  [%.2f, %.2f]\n', min(delta2(:)), max(delta2(:)));
fprintf('  All features: [%.2f, %.2f]\n', min(features(:)), max(features(:)));

fprintf('\nFeature means:\n');
fprintf('  MFCC:         %.4f\n', mean(mfcc_coeffs(:)));
fprintf('  Delta:        %.4f\n', mean(delta(:)));
fprintf('  Delta-Delta:  %.4f\n', mean(delta2(:)));

fprintf('\nFeature std deviations:\n');
fprintf('  MFCC:         %.4f\n', std(mfcc_coeffs(:)));
fprintf('  Delta:        %.4f\n', std(delta(:)));
fprintf('  Delta-Delta:  %.4f\n', std(delta2(:)));

% =========================================================================
% Show coefficient importance (variance)
% =========================================================================
fprintf('\n========================================\n');
fprintf('     COEFFICIENT VARIANCE\n');
fprintf('========================================\n\n');

mfcc_var = var(mfcc_coeffs);
delta_var = var(delta);
delta2_var = var(delta2);

fprintf('MFCC coefficient variances:\n');
for i = 1:length(mfcc_var)
    fprintf('  c%-2d: %.4f\n', i-1, mfcc_var(i));
end

% =========================================================================
% Additional visualization: Correlation matrix
% =========================================================================
figure('Name', 'Feature Correlation', 'Position', [200 200 1000 800]);

% MFCC correlation
subplot(2,2,1);
imagesc(corr(mfcc_coeffs));
colorbar; colormap('jet'); caxis([-1 1]);
title('MFCC Correlation Matrix');
xlabel('Coefficient'); ylabel('Coefficient');

% Delta correlation
subplot(2,2,2);
imagesc(corr(delta));
colorbar; colormap('jet'); caxis([-1 1]);
title('Delta Correlation Matrix');
xlabel('Coefficient'); ylabel('Coefficient');

% Delta-delta correlation
subplot(2,2,3);
imagesc(corr(delta2));
colorbar; colormap('jet'); caxis([-1 1]);
title('Delta-Delta Correlation Matrix');
xlabel('Coefficient'); ylabel('Coefficient');

% All features correlation (first 20x20 for visibility)
subplot(2,2,4);
imagesc(corr(features(:,1:20)));
colorbar; colormap('jet'); caxis([-1 1]);
title('First 20 Features Correlation');
xlabel('Feature'); ylabel('Feature');

% =========================================================================
% Example: How to use features for training
% =========================================================================
fprintf('\n========================================\n');
fprintf('     NEXT STEPS\n');
fprintf('========================================\n\n');

fprintf('Your features are ready for machine learning!\n\n');
fprintf('Example usage:\n');
fprintf('  1. Extract features from all speakers:\n');
fprintf('     >> run extract_features.m\n\n');
fprintf('  2. Train a classifier (e.g., GMM, VQ):\n');
fprintf('     >> model = train_gmm(features);\n\n');
fprintf('  3. Test on new audio:\n');
fprintf('     >> score = test_speaker(model, test_features);\n\n');

fprintf('========================================\n\n');
