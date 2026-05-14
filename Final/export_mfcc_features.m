clear; clc;

fprintf('Batch MFCC Export for Speaker Recognition\n\n');

alpha        = 0.97;
frame_length = 256;
hop_size     = 100;
nfft         = 512;
num_filters  = 26;
num_coeffs   = 13;
delta_N      = 2;

sets = {'train', 'test'};
min_len = Inf;
target_fs = [];

fprintf('Scanning audio files...\n');

for s = 1:length(sets)
    input_dir = fullfile('data', sets{s});
    wav_files = dir(fullfile(input_dir, '*.wav'));

    if isempty(wav_files)
        warning('No WAV files found in %s', input_dir);
        continue;
    end

    for i = 1:length(wav_files)
        wav_path = fullfile(input_dir, wav_files(i).name);
        [audio, fs] = audioread(wav_path);

        if size(audio, 2) > 1
            audio = mean(audio, 2);
        end

        if isempty(target_fs)
            target_fs = fs;
        elseif fs ~= target_fs
            error('Sampling rate mismatch in %s. Expected %d Hz, got %d Hz.', ...
                  wav_files(i).name, target_fs, fs);
        end

        min_len = min(min_len, length(audio));

        fprintf('  %s/%s: %d samples\n', ...
                sets{s}, wav_files(i).name, length(audio));
    end
end

if isinf(min_len)
    error('No audio files found in data/train or data/test.');
end

fprintf('\nMinimum audio length: %d samples (%.2f sec @ %d Hz)\n\n', ...
        min_len, min_len / target_fs, target_fs);

output_base = 'exported_features';

if ~exist(output_base, 'dir')
    mkdir(output_base);
end

for s = 1:length(sets)
    set_name = sets{s};
    input_dir = fullfile('data', set_name);
    output_dir = fullfile(output_base, set_name);

    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    wav_files = dir(fullfile(input_dir, '*.wav'));

    fprintf('Processing %s set...\n', upper(set_name));

    for i = 1:length(wav_files)
        wav_path = fullfile(input_dir, wav_files(i).name);
        [audio, fs] = audioread(wav_path);

        if size(audio, 2) > 1
            audio = mean(audio, 2);
        end

        audio = audio(1:min_len);

        [~, speaker_id] = fileparts(wav_files(i).name);

        emphasized = preemphasis(audio, alpha);

        frames = frame_signal(emphasized, frame_length, hop_size);

        windowed_frames = apply_window(frames);

        power_spectrum = compute_power_spectrum(windowed_frames, nfft);

        mel_energies = apply_mel_filterbank(power_spectrum, fs, nfft, num_filters);

        log_mel = apply_log(mel_energies);

        mfcc_coeffs = apply_dct(log_mel, num_coeffs);

        delta_mfcc = compute_delta(mfcc_coeffs, delta_N);

        delta2_mfcc = compute_delta(delta_mfcc, delta_N);

        features = [mfcc_coeffs; delta_mfcc; delta2_mfcc];

        output_file = fullfile(output_dir, [speaker_id '_mfcc.mat']);

        save(output_file, ...
             'features', ...
             'mfcc_coeffs', ...
             'delta_mfcc', ...
             'delta2_mfcc', ...
             'speaker_id', ...
             'fs');

        fprintf('  [%d/%d] %s -> %d × %d -> %s\n', ...
                i, length(wav_files), wav_files(i).name, ...
                size(features, 1), size(features, 2), output_file);
    end

    fprintf('\n');
end

metadata.speakers = {};

train_files = dir(fullfile('data', 'train', '*.wav'));

for i = 1:length(train_files)
    [~, speaker_id] = fileparts(train_files(i).name);
    metadata.speakers{end + 1} = speaker_id;
end

metadata.num_speakers = length(metadata.speakers);
metadata.feature_dim = 39;
metadata.min_audio_length = min_len;
metadata.fs = target_fs;
metadata.feature_description = '13 MFCC + 13 Delta + 13 Delta-Delta';

metadata.parameters.alpha = alpha;
metadata.parameters.frame_length = frame_length;
metadata.parameters.hop_size = hop_size;
metadata.parameters.nfft = nfft;
metadata.parameters.num_filters = num_filters;
metadata.parameters.num_coeffs = num_coeffs;
metadata.parameters.delta_N = delta_N;

save(fullfile(output_base, 'metadata.mat'), 'metadata');

fprintf('Export complete.\n');
fprintf('Output directory: %s\n', fullfile(pwd, output_base));
fprintf('Speakers: %d\n', metadata.num_speakers);
fprintf('Feature dimension: %d\n', metadata.feature_dim);
fprintf('Feature shape: 39 × M\n');
fprintf('Audio length: %d samples (%.2f sec)\n', ...
        min_len, min_len / target_fs);