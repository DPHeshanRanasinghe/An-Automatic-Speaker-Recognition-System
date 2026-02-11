% TEST_MFCC.M - Comprehensive test script for MFCC implementation
%
% This script tests your MFCC implementation step-by-step, visualizes
% the results, and helps you debug any issues.
%
% USAGE:
%   1. Place this file in the same directory as your MFCC functions
%   2. Make sure you have a test audio file (e.g., S1.wav from TRAIN folder)
%   3. Run this script in MATLAB
%   4. Check the outputs and visualizations
%
% WHAT THIS SCRIPT DOES:
%   - Loads a test audio file
%   - Extracts MFCC features
%   - Displays statistics
%   - Creates visualizations
%   - Tests each step of the pipeline individually
%   - Checks for common errors (NaN, Inf, dimension mismatches)

clear; clc; close all;

fprintf('\n');
fprintf('==================================================\n');
fprintf('       MFCC IMPLEMENTATION TEST SCRIPT\n');
fprintf('==================================================\n\n');

% =========================================================================
% CONFIGURATION
% =========================================================================
% Change this to point to one of your audio files
audio_file = 'S1.wav';  % Or 'TRAIN/S1.WAV' if in subdirectory

% Check if file exists
if ~exist(audio_file, 'file')
    error(['Audio file not found: %s\n' ...
           'Please update audio_file variable to point to a valid .wav file'], ...
          audio_file);
end

% =========================================================================
% STEP 1: LOAD AUDIO
% =========================================================================
fprintf('STEP 1: Loading audio file...\n');
fprintf('  File: %s\n', audio_file);

[signal, fs] = audioread(audio_file);

fprintf('  Samples: %d\n', length(signal));
fprintf('  Duration: %.2f seconds\n', length(signal)/fs);
fprintf('  Sampling rate: %d Hz\n', fs);
fprintf('  Channels: %d\n', size(signal, 2));

% If stereo, convert to mono
if size(signal, 2) > 1
    fprintf('  Converting stereo to mono...\n');
    signal = mean(signal, 2);
end

fprintf('  ✓ Audio loaded successfully\n\n');

% =========================================================================
% STEP 2: EXTRACT 39-DIMENSIONAL MFCC FEATURES
% =========================================================================
fprintf('STEP 2: Extracting 39-dimensional MFCC features...\n\n');

tic;  % Start timer
[features, mfcc_coeffs, delta_coeffs, delta2_coeffs] = mfcc(signal, fs, true);
elapsed = toc;  % End timer

fprintf('\n  Computation time: %.4f seconds\n', elapsed);
fprintf('  ✓ Feature extraction complete\n\n');

% =========================================================================
% STEP 3: BASIC STATISTICS
% =========================================================================
fprintf('STEP 3: Checking statistics...\n');

fprintf('  All features range: [%.2f, %.2f]\n', min(features(:)), max(features(:)));
fprintf('  All features mean: %.4f\n', mean(features(:)));
fprintf('  All features std: %.4f\n\n', std(features(:)));

fprintf('  MFCC range: [%.2f, %.2f]\n', min(mfcc_coeffs(:)), max(mfcc_coeffs(:)));
fprintf('  Delta range: [%.2f, %.2f]\n', min(delta_coeffs(:)), max(delta_coeffs(:)));
fprintf('  Delta-Delta range: [%.2f, %.2f]\n', min(delta2_coeffs(:)), max(delta2_coeffs(:)));

% Check for problematic values
num_nan = sum(isnan(features(:)));
num_inf = sum(isinf(features(:)));

if num_nan > 0
    fprintf('  ⚠ WARNING: %d NaN values detected!\n', num_nan);
    fprintf('    → Check eps value in apply_log.m\n');
else
    fprintf('  ✓ No NaN values\n');
end

if num_inf > 0
    fprintf('  ⚠ WARNING: %d Inf values detected!\n', num_inf);
    fprintf('    → Check log(0) handling in apply_log.m\n');
else
    fprintf('  ✓ No Inf values\n');
end

% Typical MFCC values are in range [−50, 50] or so
if min(features(:)) < -100 || max(features(:)) > 100
    fprintf('  ⚠ WARNING: Feature values outside typical range\n');
    fprintf('    → Typical range is roughly [−50, 50]\n');
    fprintf('    → Check log step\n');
else
    fprintf('  ✓ Values in reasonable range\n');
end

fprintf('\n');

% =========================================================================
% STEP 4: VISUALIZATIONS - 39-DIMENSIONAL FEATURES
% =========================================================================
fprintf('STEP 4: Creating visualizations...\n');

% Figure 1: All 39 Features Heatmap
figure('Name', '39-Dimensional MFCC Features', 'Position', [100 100 1200 600]);

subplot(2,2,1);
imagesc(mfcc_coeffs');
axis xy; colorbar; colormap('jet');
title('MFCC Coefficients (13)');
xlabel('Frame'); ylabel('Coefficient');

subplot(2,2,2);
imagesc(delta_coeffs');
axis xy; colorbar; colormap('jet');
title('Delta Coefficients (13)');
xlabel('Frame'); ylabel('Coefficient');

subplot(2,2,3);
imagesc(delta2_coeffs');
axis xy; colorbar; colormap('jet');
title('Delta-Delta Coefficients (13)');
xlabel('Frame'); ylabel('Coefficient');

subplot(2,2,4);
% Normalize each section for better visualization
features_norm = features;
features_norm(:,1:13) = (features(:,1:13) - min(features(:,1:13),[],1)) ./ (max(features(:,1:13),[],1) - min(features(:,1:13),[],1));
features_norm(:,14:26) = (features(:,14:26) - min(features(:,14:26),[],1)) ./ (max(features(:,14:26),[],1) - min(features(:,14:26),[],1));
features_norm(:,27:39) = (features(:,27:39) - min(features(:,27:39),[],1)) ./ (max(features(:,27:39),[],1) - min(features(:,27:39),[],1));

imagesc(features_norm');
axis xy; colorbar; colormap('jet');
title('All 39 Features (Normalized per Section)');
xlabel('Frame'); ylabel('Feature Dimension');
hold on;
plot([0.5 size(features,1)+0.5], [13.5 13.5], 'w--', 'LineWidth', 2);
plot([0.5 size(features,1)+0.5], [26.5 26.5], 'w--', 'LineWidth', 2);
text(5, 7, 'MFCC', 'Color', 'white', 'FontWeight', 'bold', 'FontSize', 10);
text(5, 20, 'Delta', 'Color', 'white', 'FontWeight', 'bold', 'FontSize', 10);
text(5, 33, 'Δ-Δ', 'Color', 'white', 'FontWeight', 'bold', 'FontSize', 10);
hold off;

sgtitle(sprintf('39-Dimensional MFCC Features: %s', audio_file), 'FontSize', 14, 'Interpreter', 'none');
fprintf('  ✓ Created 39-feature heatmap\n');

% Figure 2: Time Series Comparison - MFCC, Delta, Delta-Delta
figure('Name', 'Coefficient Time Series Comparison', 'Position', [150 150 1400 800]);

for i = 1:min(12, size(mfcc_coeffs, 2))
    subplot(4, 4, i);
    plot(mfcc_coeffs(:, i), 'b', 'LineWidth', 1.5);
    hold on;
    plot(delta_coeffs(:, i), 'r', 'LineWidth', 1);
    plot(delta2_coeffs(:, i), 'g', 'LineWidth', 1);
    hold off;
    grid on;
    title(sprintf('Coeff %d', i-1), 'FontSize', 10);
    xlabel('Frame');
    ylabel('Value');
    if i == 1
        legend('MFCC', 'Delta', 'Δ-Δ', 'Location', 'best', 'FontSize', 8);
    end
end

% Last coefficient
subplot(4, 4, 13);
plot(mfcc_coeffs(:, 13), 'b', 'LineWidth', 1.5);
hold on;
plot(delta_coeffs(:, 13), 'r', 'LineWidth', 1);
plot(delta2_coeffs(:, 13), 'g', 'LineWidth', 1);
hold off;
grid on;
title('Coeff 12', 'FontSize', 10);
xlabel('Frame');
ylabel('Value');

sgtitle('MFCC Coefficients Over Time (with Delta features)', 'FontSize', 14);
fprintf('  ✓ Created coefficient time series\n');

% Figure 3: Feature Statistics
figure('Name', 'Feature Statistics', 'Position', [200 200 1200 400]);

subplot(1, 3, 1);
bar([mean(mfcc_coeffs); mean(delta_coeffs); mean(delta2_coeffs)]');
legend('MFCC', 'Delta', 'Δ-Δ', 'Location', 'best');
title('Mean of Each Coefficient');
xlabel('Coefficient Index');
ylabel('Mean Value');
grid on;

subplot(1, 3, 2);
bar([std(mfcc_coeffs); std(delta_coeffs); std(delta2_coeffs)]');
legend('MFCC', 'Delta', 'Δ-Δ', 'Location', 'best');
title('Std Dev of Each Coefficient');
xlabel('Coefficient Index');
ylabel('Std Dev');
grid on;

subplot(1, 3, 3);
boxplot([mfcc_coeffs(:,1:3), delta_coeffs(:,1:3), delta2_coeffs(:,1:3)], ...
        'Labels', {'M0','M1','M2','D0','D1','D2','DD0','DD1','DD2'});
title('Distribution of First 3 Coefficients');
ylabel('Value');
grid on;

sgtitle('Feature Statistics Comparison', 'FontSize', 14);
fprintf('  ✓ Created statistics plots\n\n');

% =========================================================================
% STEP 5: TEST INDIVIDUAL PIPELINE STAGES
% =========================================================================
fprintf('STEP 5: Testing individual pipeline stages...\n');

% Parameters (same as in mfcc.m)
alpha = 0.97;
frame_length = 256;
hop_size = 100;
nfft = 512;
num_filters = 26;
num_coeffs = 13;

try
    % Stage 1: Pre-emphasis
    emphasized = preemphasis(signal, alpha);
    fprintf('  ✓ Stage 1 (Pre-emphasis): OK [%d samples]\n', length(emphasized));
    
    % Stage 2: Framing
    frames = frame_signal(emphasized, frame_length, hop_size);
    fprintf('  ✓ Stage 2 (Framing): OK [%d frames × %d]\n', size(frames,1), size(frames,2));
    
    % Stage 3: Windowing
    windowed = apply_window(frames);
    fprintf('  ✓ Stage 3 (Windowing): OK [%d × %d]\n', size(windowed,1), size(windowed,2));
    
    % Stage 4: Power spectrum
    power = compute_power_spectrum(windowed, nfft);
    fprintf('  ✓ Stage 4 (Power Spectrum): OK [%d × %d]\n', size(power,1), size(power,2));
    
    % Stage 5: Mel filterbank
    mel_energies = apply_mel_filterbank(power, fs, nfft, num_filters);
    fprintf('  ✓ Stage 5 (Mel Filterbank): OK [%d × %d]\n', size(mel_energies,1), size(mel_energies,2));
    
    % Stage 6: Log
    log_mel = apply_log(mel_energies);
    fprintf('  ✓ Stage 6 (Log): OK [%d × %d]\n', size(log_mel,1), size(log_mel,2));
    
    % Stage 7: DCT
    mfcc_test = apply_dct(log_mel, num_coeffs);
    fprintf('  ✓ Stage 7 (DCT): OK [%d × %d]\n', size(mfcc_test,1), size(mfcc_test,2));
    
    fprintf('  ✓ All pipeline stages working correctly!\n\n');
    
catch ME
    fprintf('  ✗ ERROR in pipeline stage: %s\n', ME.message);
    fprintf('  Stage: %s\n', ME.stack(1).name);
    fprintf('  Line: %d\n\n', ME.stack(1).line);
end

% =========================================================================
% STEP 6: VISUALIZE INTERMEDIATE STAGES
% =========================================================================
fprintf('STEP 6: Visualizing intermediate stages...\n');

figure('Name', 'Pipeline Stages', 'Position', [250 250 1100 800]);

% Original signal
subplot(4, 2, 1);
plot(signal(1:min(5000, length(signal))));
title('1. Input Signal');
xlabel('Sample'); ylabel('Amplitude');
grid on;

% Pre-emphasized signal
subplot(4, 2, 2);
plot(emphasized(1:min(5000, length(emphasized))));
title('2. After Pre-Emphasis');
xlabel('Sample'); ylabel('Amplitude');
grid on;

% One frame before windowing
subplot(4, 2, 3);
plot(frames(10, :));
title('3. One Frame (before window)');
xlabel('Sample'); ylabel('Amplitude');
grid on;

% One frame after windowing
subplot(4, 2, 4);
plot(windowed(10, :));
title('4. One Frame (after Hamming)');
xlabel('Sample'); ylabel('Amplitude');
grid on;

% Power spectrum
subplot(4, 2, 5);
imagesc(10*log10(power' + eps)); axis xy; colorbar;
title('5. Power Spectrogram (dB)');
xlabel('Frame'); ylabel('Freq Bin');

% Mel energies
subplot(4, 2, 6);
imagesc(mel_energies'); axis xy; colorbar;
title('6. Mel Filterbank Energies');
xlabel('Frame'); ylabel('Mel Band');

% Log-mel energies
subplot(4, 2, 7);
imagesc(log_mel'); axis xy; colorbar;
title('7. Log-Mel Energies');
xlabel('Frame'); ylabel('Mel Band');

% Final MFCC
subplot(4, 2, 8);
imagesc(mfcc_coeffs'); axis xy; colorbar;
title('8. MFCC Coefficients');
xlabel('Frame'); ylabel('Coefficient');

sgtitle('MFCC Pipeline: All Stages', 'FontSize', 14);
fprintf('  ✓ Created pipeline visualization\n\n');

% =========================================================================
% SUMMARY
% =========================================================================
fprintf('==================================================\n');
fprintf('                 TEST SUMMARY\n');
fprintf('==================================================\n');
fprintf('✓ Audio loaded: %s\n', audio_file);
fprintf('✓ Features computed:\n');
fprintf('  - MFCC: %d frames × %d coeffs\n', size(mfcc_coeffs,1), size(mfcc_coeffs,2));
fprintf('  - Delta: %d frames × %d coeffs\n', size(delta_coeffs,1), size(delta_coeffs,2));
fprintf('  - Delta-Delta: %d frames × %d coeffs\n', size(delta2_coeffs,1), size(delta2_coeffs,2));
fprintf('  - Combined: %d frames × %d features\n', size(features,1), size(features,2));
fprintf('✓ Processing time: %.4f seconds\n', elapsed);
fprintf('✓ All visualizations created\n');

if num_nan == 0 && num_inf == 0
    fprintf('✓ No problematic values (NaN/Inf)\n');
else
    fprintf('⚠ WARNING: Found NaN (%d) or Inf (%d) values\n', num_nan, num_inf);
end

fprintf('\nYour 39-dimensional MFCC implementation is ready!\n');
fprintf('Next steps:\n');
fprintf('  1. Run this test on all 8 training files\n');
fprintf('  2. Implement vqlbg.m for vector quantization\n');
fprintf('  3. Integrate with train.m and test.m\n');
fprintf('==================================================\n\n');

% =========================================================================
% OPTIONAL: SAVE RESULTS
% =========================================================================
% Uncomment to save MFCC features and figures

% save('mfcc_test_results.mat', 'features', 'mfcc_coeffs', 'delta_coeffs', 'delta2_coeffs', 'signal', 'fs');
% fprintf('Results saved to mfcc_test_results.mat\n');

% saveas(gcf, 'mfcc_pipeline.png');
% fprintf('Pipeline figure saved to mfcc_pipeline.png\n');
