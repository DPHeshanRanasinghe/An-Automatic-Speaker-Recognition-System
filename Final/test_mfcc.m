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
% STEP 2: EXTRACT MFCC
% =========================================================================
fprintf('STEP 2: Extracting MFCC features...\n');

tic;  % Start timer
coeffs = mfcc(signal, fs);
elapsed = toc;  % End timer

fprintf('  Computation time: %.4f seconds\n', elapsed);
fprintf('  Output size: %d × %d\n', size(coeffs, 1), size(coeffs, 2));
fprintf('  ✓ MFCC extraction complete\n\n');

% =========================================================================
% STEP 3: BASIC STATISTICS
% =========================================================================
fprintf('STEP 3: Checking statistics...\n');

fprintf('  MFCC range: [%.2f, %.2f]\n', min(coeffs(:)), max(coeffs(:)));
fprintf('  MFCC mean: %.4f\n', mean(coeffs(:)));
fprintf('  MFCC std: %.4f\n', std(coeffs(:)));

% Check for problematic values
num_nan = sum(isnan(coeffs(:)));
num_inf = sum(isinf(coeffs(:)));

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
if min(coeffs(:)) < -100 || max(coeffs(:)) > 100
    fprintf('  ⚠ WARNING: MFCC values outside typical range\n');
    fprintf('    → Typical range is roughly [−50, 50]\n');
    fprintf('    → Check log step\n');
else
    fprintf('  ✓ Values in reasonable range\n');
end

fprintf('\n');

% =========================================================================
% STEP 4: VISUALIZATIONS
% =========================================================================
fprintf('STEP 4: Creating visualizations...\n');

% Figure 1: MFCC Heatmap
figure('Name', 'MFCC Features', 'Position', [100 100 800 500]);
imagesc(coeffs');
axis xy;
colorbar;
colormap('jet');
xlabel('Frame Number', 'FontSize', 12);
ylabel('MFCC Coefficient', 'FontSize', 12);
title(sprintf('MFCC Features: %s', audio_file), 'FontSize', 14, 'Interpreter', 'none');

% Add grid
hold on;
% Vertical grid lines every 10 frames
for i = 10:10:size(coeffs,1)
    plot([i i], [0.5 size(coeffs,2)+0.5], 'w--', 'LineWidth', 0.5);
end
% Horizontal grid lines between coefficients
for i = 1.5:1:size(coeffs,2)
    plot([0.5 size(coeffs,1)+0.5], [i i], 'w--', 'LineWidth', 0.5);
end
hold off;

fprintf('  ✓ Created MFCC heatmap\n');

% Figure 2: Individual MFCC Coefficients Over Time
figure('Name', 'MFCC Coefficients Time Series', 'Position', [150 150 1000 700]);
num_coeffs_to_plot = min(13, size(coeffs, 2));

for i = 1:num_coeffs_to_plot
    subplot(4, 4, i);
    plot(coeffs(:, i), 'LineWidth', 1.5);
    grid on;
    title(sprintf('c_{%d}', i-1), 'FontSize', 11);  % 0-indexed
    xlabel('Frame');
    ylabel('Value');
end

sgtitle('MFCC Coefficients Over Time', 'FontSize', 14);
fprintf('  ✓ Created coefficient time series\n');

% Figure 3: MFCC Statistics per Coefficient
figure('Name', 'MFCC Statistics', 'Position', [200 200 900 400]);

subplot(1, 3, 1);
bar(mean(coeffs, 1));
grid on;
title('Mean of Each Coefficient');
xlabel('Coefficient Index');
ylabel('Mean Value');

subplot(1, 3, 2);
bar(std(coeffs, 0, 1));
grid on;
title('Std Dev of Each Coefficient');
xlabel('Coefficient Index');
ylabel('Std Dev');

subplot(1, 3, 3);
bar(range(coeffs, 1));
grid on;
title('Range of Each Coefficient');
xlabel('Coefficient Index');
ylabel('Range (max − min)');

sgtitle('MFCC Coefficient Statistics', 'FontSize', 14);
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
imagesc(coeffs'); axis xy; colorbar;
title('8. MFCC (Final Output)');
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
fprintf('✓ MFCC computed: %d frames × %d coeffs\n', size(coeffs,1), size(coeffs,2));
fprintf('✓ Processing time: %.4f seconds\n', elapsed);
fprintf('✓ All visualizations created\n');

if num_nan == 0 && num_inf == 0
    fprintf('✓ No problematic values (NaN/Inf)\n');
else
    fprintf('⚠ WARNING: Found NaN (%d) or Inf (%d) values\n', num_nan, num_inf);
end

fprintf('\nYour MFCC implementation is ready to use!\n');
fprintf('Next steps:\n');
fprintf('  1. Run this test on all 8 training files\n');
fprintf('  2. Implement vqlbg.m for vector quantization\n');
fprintf('  3. Integrate with train.m and test.m\n');
fprintf('==================================================\n\n');

% =========================================================================
% OPTIONAL: SAVE RESULTS
% =========================================================================
% Uncomment to save MFCC features and figures

% save('mfcc_test_results.mat', 'coeffs', 'signal', 'fs');
% fprintf('Results saved to mfcc_test_results.mat\n');

% saveas(gcf, 'mfcc_pipeline.png');
% fprintf('Pipeline figure saved to mfcc_pipeline.png\n');
