function speaker_database = build_speaker_database(train_folder)
% BUILD_SPEAKER_DATABASE - Create MFCC feature database from training audio files
%
% This function extracts MFCC features from all training audio files and
% creates a database structure for speaker recognition.
%
% INPUTS:
%   train_folder - path to folder containing training .wav files
%
% OUTPUTS:
%   speaker_database - struct array with fields:
%       .speaker_id   - speaker identifier (e.g., 's1', 's2', ...)
%       .features     - MFCC feature matrix (num_frames × 39)
%       .mean_vector  - mean feature vector (1 × 39)
%       .cov_matrix   - covariance matrix (39 × 39)
%       .filename     - original audio filename
%
% USAGE:
%   database = build_speaker_database('data/train');
%   save('speaker_database.mat', 'database');

    fprintf('\n========================================\n');
    fprintf('Building Speaker Database\n');
    fprintf('========================================\n\n');
    
    % Get all .wav files in training folder
    wav_files = dir(fullfile(train_folder, '*.wav'));
    num_speakers = length(wav_files);
    
    if num_speakers == 0
        error('No .wav files found in %s', train_folder);
    end
    
    fprintf('Found %d speakers to train\n\n', num_speakers);
    
    % Initialize speaker database
    speaker_database = struct('speaker_id', {}, 'features', {}, ...
                             'mean_vector', {}, 'cov_matrix', {}, ...
                             'filename', {});
    
    % Process each training file
    for i = 1:num_speakers
        fprintf('[%d/%d] Processing: %s\n', i, num_speakers, wav_files(i).name);
        
        % Read audio file
        file_path = fullfile(train_folder, wav_files(i).name);
        [audio, fs] = audioread(file_path);
        
        % Convert stereo to mono if needed
        if size(audio, 2) > 1
            audio = mean(audio, 2);
        end
        
        % Extract MFCC features (39-dimensional)
        fprintf('   - Extracting MFCC features...\n');
        features = mfcc(audio, fs, false);  % Silent mode
        
        % Extract speaker ID from filename (e.g., 's1.wav' -> 's1')
        [~, speaker_id, ~] = fileparts(wav_files(i).name);
        
        % Compute statistical model
        fprintf('   - Computing statistical model...\n');
        mean_vector = mean(features, 1);     % Mean of each feature dimension
        cov_matrix = cov(features);          % Covariance matrix
        
        % Add regularization to prevent singular covariance matrix
        epsilon = 1e-6;
        cov_matrix = cov_matrix + epsilon * eye(size(cov_matrix));
        
        % Store in database
        speaker_database(i).speaker_id = speaker_id;
        speaker_database(i).features = features;
        speaker_database(i).mean_vector = mean_vector;
        speaker_database(i).cov_matrix = cov_matrix;
        speaker_database(i).filename = wav_files(i).name;
        
        fprintf('   - Extracted %d frames with %d features each\n\n', ...
                size(features, 1), size(features, 2));
    end
    
    fprintf('========================================\n');
    fprintf('Database built successfully!\n');
    fprintf('Total speakers: %d\n', num_speakers);
    fprintf('========================================\n\n');
end
