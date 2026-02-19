function [features, mfcc_coeffs, delta_coeffs, delta2_coeffs] = mfcc(audio_path, visualize)

if nargin < 2
    visualize = false;
end

% MFCC parameters
alpha = 0.97;           % Pre-emphasis coefficient
frame_length = 256;     % Frame length (16ms at 16kHz)
hop_size = 100;         % Hop size (6.25ms at 16kHz, 62.5% overlap)
nfft = 512;             % FFT size
num_filters = 26;       % Number of mel filters
num_coeffs = 13;        % Number of MFCC coefficients
delta_N = 2;            % Delta window size

if ~exist(audio_path, 'file')
    % Try in data/train folder
    test_path = fullfile('data', 'train', audio_path);
    if exist(test_path, 'file')
        audio_path = test_path;
    else
        % Try in data/test folder
        test_path = fullfile('data', 'test', audio_path);
        if exist(test_path, 'file')
            audio_path = test_path;
        else
            error('Audio file not found: %s', audio_path);
        end
    end
end

[signal, fs] = audioread(audio_path);

% Convert stereo to mono if needed
if size(signal, 2) > 1
    signal = mean(signal, 2);
end

% Ensure column vector
if isrow(signal)
    signal = signal(:);
end

fprintf('\n=== MFCC Feature Extraction ===\n');
fprintf('File: %s\n', audio_path);
fprintf('Samples: %d | Duration: %.2f sec | Fs: %d Hz\n', ...
        length(signal), length(signal)/fs, fs);


emphasized = preemphasis(signal, alpha);

frames = frame_signal(emphasized, frame_length, hop_size);
fprintf('\n');

windowed_frames = apply_window(frames);
fprintf('\n');

power_spectrum = compute_power_spectrum(windowed_frames, nfft);
fprintf('Power spectrum: %d frames × %d bins\n', ...
        size(power_spectrum,1), size(power_spectrum,2));

mel_energies = apply_mel_filterbank(power_spectrum, fs, nfft, num_filters);
fprintf('Mel energies: %d frames × %d filters\n', ...
        size(mel_energies,1), size(mel_energies,2));

log_mel = apply_log(mel_energies);
fprintf('Log-mel energies: %d frames × %d filters\n', ...
        size(log_mel,1), size(log_mel,2));

mfcc_coeffs = apply_dct(log_mel, num_coeffs);
fprintf('MFCC coefficients: %d frames × %d coeffs\n', ...
        size(mfcc_coeffs,1), size(mfcc_coeffs,2));

% Compute delta features (inline to avoid path issues)
delta_coeffs = compute_delta(mfcc_coeffs, delta_N);
delta2_coeffs = compute_delta(delta_coeffs, delta_N);

fprintf('Delta coefficients: %d frames × %d coeffs\n', ...
        size(delta_coeffs,1), size(delta_coeffs,2));
fprintf('Delta-delta coefficients: %d frames × %d coeffs\n', ...
        size(delta2_coeffs,1), size(delta2_coeffs,2));

features = [mfcc_coeffs, delta_coeffs, delta2_coeffs];

fprintf('\n✓ Final features: %d frames × %d dimensions\n', ...
        size(features,1), size(features,2));
fprintf('  - MFCC: columns 1-13\n');
fprintf('  - Delta: columns 14-26\n');
fprintf('  - Delta-Delta: columns 27-39\n');

if any(isnan(features(:)))
    warning('%d NaN values detected in features!', sum(isnan(features(:))));
end
if any(isinf(features(:)))
    warning('%d Inf values detected in features!', sum(isinf(features(:))));
end

if visualize
    visualize_mfcc_features(features, mfcc_coeffs, delta_coeffs, delta2_coeffs, ...
                           signal, fs, audio_path);
end


end

function visualize_mfcc_features(features, mfcc, delta, delta2, signal, fs, filepath)

[~, filename, ~] = fileparts(filepath);

% Figure 1: All 39 features
figure('Name', 'MFCC Features - 39 Dimensions', 'Position', [50 50 1200 700]);

subplot(2,2,1);
imagesc(mfcc');
axis xy; colorbar; colormap('jet');
title('MFCC Coefficients (13)', 'FontSize', 12);
xlabel('Frame'); ylabel('Coefficient');

subplot(2,2,2);
imagesc(delta');
axis xy; colorbar; colormap('jet');
title('Delta Coefficients (13)', 'FontSize', 12);
xlabel('Frame'); ylabel('Coefficient');

subplot(2,2,3);
imagesc(delta2');
axis xy; colorbar; colormap('jet');
title('Delta-Delta Coefficients (13)', 'FontSize', 12);
xlabel('Frame'); ylabel('Coefficient');

subplot(2,2,4);
imagesc(features');
axis xy; colorbar; colormap('jet');
title('All 39-Dimensional Features', 'FontSize', 12);
xlabel('Frame'); ylabel('Feature Dimension');
% Add separation lines
hold on;
plot([0.5 size(features,1)+0.5], [13.5 13.5], 'w--', 'LineWidth', 2);
plot([0.5 size(features,1)+0.5], [26.5 26.5], 'w--', 'LineWidth', 2);
text(size(features,1)*0.02, 7, 'MFCC', 'Color', 'white', 'FontWeight', 'bold');
text(size(features,1)*0.02, 20, 'Delta', 'Color', 'white', 'FontWeight', 'bold');
text(size(features,1)*0.02, 32, 'Delta2', 'Color', 'white', 'FontWeight', 'bold');
hold off;

sgtitle(sprintf('MFCC Feature Extraction: %s', filename), 'FontSize', 14, 'Interpreter', 'none');

% Figure 2: Individual coefficient plots
figure('Name', 'MFCC Time Series', 'Position', [100 100 1400 800]);

for i = 1:min(12, size(mfcc,2))
    subplot(4, 4, i);
    plot(mfcc(:, i), 'b', 'LineWidth', 1.5);
    hold on;
    plot(delta(:, i), 'r', 'LineWidth', 1);
    plot(delta2(:, i), 'g', 'LineWidth', 1);
    hold off;
    grid on;
    title(sprintf('Coeff %d', i-1), 'FontSize', 10);
    if i == 1
        legend('MFCC', 'Delta', 'Delta2', 'Location', 'best', 'FontSize', 8);
    end
    xlabel('Frame');
end

% Energy coefficient
subplot(4, 4, 13);
plot(mfcc(:, 13), 'b', 'LineWidth', 1.5);
hold on;
plot(delta(:, 13), 'r', 'LineWidth', 1);
plot(delta2(:, 13), 'g', 'LineWidth', 1);
hold off;
grid on;
title('Coeff 12 (Energy)', 'FontSize', 10);
xlabel('Frame');

% Waveform
subplot(4, 4, [14 15 16]);
time = (0:length(signal)-1) / fs;
plot(time, signal, 'k', 'LineWidth', 0.5);
grid on;
title('Original Waveform', 'FontSize', 10);
xlabel('Time (seconds)');
ylabel('Amplitude');

sgtitle(sprintf('MFCC Coefficients Over Time: %s', filename), 'FontSize', 14, 'Interpreter', 'none');

% Figure 3: Statistics
figure('Name', 'Feature Statistics', 'Position', [150 150 1200 400]);

subplot(1,3,1);
bar([mean(mfcc); mean(delta); mean(delta2)]');
legend('MFCC', 'Delta', 'Delta2', 'Location', 'best');
title('Mean of Each Coefficient');
xlabel('Coefficient Index');
ylabel('Mean Value');
grid on;

subplot(1,3,2);
bar([std(mfcc); std(delta); std(delta2)]');
legend('MFCC', 'Delta', 'Delta2', 'Location', 'best');
title('Std Dev of Each Coefficient');
xlabel('Coefficient Index');
ylabel('Standard Deviation');
grid on;

subplot(1,3,3);
boxplot([mfcc(:,1:3), delta(:,1:3), delta2(:,1:3)], ...
        'Labels', {'M0','M1','M2','D0','D1','D2','DD0','DD1','DD2'});
title('Distribution of First 3 Coefficients');
ylabel('Value');
grid on;

sgtitle(sprintf('Feature Statistics: %s', filename), 'FontSize', 14, 'Interpreter', 'none');

end


% =========================================================================
% HELPER FUNCTION: Compute Delta (Velocity) Features
% =========================================================================
function delta = compute_delta(mfcc, N)
% Compute delta (first derivative) features using regression formula
% 
% INPUTS:
%   mfcc - MFCC coefficients (num_frames × num_coeffs)
%   N    - regression window size (default: 2)
%
% OUTPUT:
%   delta - delta coefficients (same size as input)

if nargin < 2
    N = 2;
end

[T, D] = size(mfcc);
delta = zeros(T, D);
denom = 2 * sum((1:N).^2);

for n = 1:N
    t_plus  = min(T, (1:T) + n);
    t_minus = max(1, (1:T) - n);
    delta = delta + n * (mfcc(t_plus,:) - mfcc(t_minus,:));
end

delta = delta / denom;

end

