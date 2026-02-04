function [predicted_speaker, confidence, all_distances] = recognize_single_speaker(audio_file, speaker_database, distance_metric)
% RECOGNIZE_SINGLE_SPEAKER - Identify speaker from a single audio file
%
% This function recognizes the speaker in a single audio file by comparing
% against a pre-built speaker database.
%
% INPUTS:
%   audio_file       - path to audio file (.wav)
%   speaker_database - database created by build_speaker_database
%   distance_metric  - (optional) 'euclidean', 'cosine', or 'mahalanobis'
%                      default: 'euclidean'
%
% OUTPUTS:
%   predicted_speaker - predicted speaker ID
%   confidence        - confidence score (0-1)
%   all_distances     - struct array with distances to all speakers
%
% USAGE:
%   % Load database
%   load('speaker_database.mat');
%   
%   % Recognize speaker
%   [speaker, conf, dist] = recognize_single_speaker('unknown.wav', speaker_database);
%   fprintf('Predicted: %s (Confidence: %.2f%%)\n', speaker, conf*100);
%   
%   % Show distances to all speakers
%   for i = 1:length(dist)
%       fprintf('%s: %.4f\n', dist(i).speaker_id, dist(i).distance);
%   end

    if nargin < 3
        distance_metric = 'euclidean';
    end
    
    fprintf('\n========================================\n');
    fprintf('Speaker Recognition for Single Audio\n');
    fprintf('========================================\n\n');
    fprintf('Audio file: %s\n', audio_file);
    fprintf('Distance metric: %s\n\n', distance_metric);
    
    % Check if file exists
    if ~exist(audio_file, 'file')
        error('Audio file not found: %s', audio_file);
    end
    
    % Read audio file
    fprintf('Reading audio file...\n');
    [audio, fs] = audioread(audio_file);
    
    % Convert stereo to mono if needed
    if size(audio, 2) > 1
        audio = mean(audio, 2);
    end
    
    % Extract MFCC features
    fprintf('Extracting MFCC features...\n');
    test_features = mfcc(audio, fs, false);
    test_mean = mean(test_features, 1);
    
    fprintf('Extracted %d frames with %d features each\n\n', ...
            size(test_features, 1), size(test_features, 2));
    
    % Compute distance to each speaker
    fprintf('Computing distances to all speakers...\n\n');
    num_speakers = length(speaker_database);
    all_distances = struct('speaker_id', {}, 'distance', {});
    distances = zeros(num_speakers, 1);
    
    for i = 1:num_speakers
        % Calculate distance
        if strcmp(distance_metric, 'mahalanobis')
            diff = test_mean - speaker_database(i).mean_vector;
            try
                dist = sqrt(diff * (speaker_database(i).cov_matrix \ diff'));
            catch
                % Fallback to Euclidean
                dist = sqrt(sum(diff.^2));
            end
        elseif strcmp(distance_metric, 'cosine')
            test_norm = sqrt(sum(test_mean.^2));
            ref_norm = sqrt(sum(speaker_database(i).mean_vector.^2));
            dot_prod = sum(test_mean .* speaker_database(i).mean_vector);
            dist = 1 - (dot_prod / (test_norm * ref_norm));
        else  % euclidean
            dist = sqrt(sum((test_mean - speaker_database(i).mean_vector).^2));
        end
        
        distances(i) = dist;
        all_distances(i).speaker_id = speaker_database(i).speaker_id;
        all_distances(i).distance = dist;
        
        fprintf('  %s: %.4f\n', speaker_database(i).speaker_id, dist);
    end
    
    % Find closest match
    [min_distance, predicted_idx] = min(distances);
    predicted_speaker = speaker_database(predicted_idx).speaker_id;
    
    % Calculate confidence
    normalized_distances = distances / sum(distances);
    confidence = 1 - normalized_distances(predicted_idx);
    
    % Display result
    fprintf('\n========================================\n');
    fprintf('PREDICTION RESULT\n');
    fprintf('========================================\n');
    fprintf('Predicted Speaker: %s\n', predicted_speaker);
    fprintf('Confidence: %.2f%%\n', confidence * 100);
    fprintf('Distance: %.4f\n', min_distance);
    fprintf('========================================\n\n');
    
    % Show ranking
    fprintf('Speaker Ranking (closest to farthest):\n');
    [~, sorted_idx] = sort(distances);
    for i = 1:num_speakers
        idx = sorted_idx(i);
        fprintf('  %d. %s (distance: %.4f)\n', i, ...
                speaker_database(idx).speaker_id, distances(idx));
    end
    fprintf('\n');
end
