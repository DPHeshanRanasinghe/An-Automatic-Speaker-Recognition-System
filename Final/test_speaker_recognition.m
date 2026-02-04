function results = test_speaker_recognition(speaker_database, test_folder, distance_metric)
% TEST_SPEAKER_RECOGNITION - Test speaker recognition system
%
% This function tests the speaker recognition system by comparing test
% audio files against the trained speaker database.
%
% INPUTS:
%   speaker_database - database created by build_speaker_database
%   test_folder      - path to folder containing test .wav files
%   distance_metric  - (optional) distance metric to use:
%                      'euclidean' - Euclidean distance (default)
%                      'cosine'    - Cosine distance
%                      'mahalanobis' - Mahalanobis distance
%
% OUTPUTS:
%   results - struct array with fields:
%       .test_file        - test filename
%       .true_speaker     - ground truth speaker ID
%       .predicted_speaker - predicted speaker ID
%       .correct          - boolean indicating correct prediction
%       .distances        - distances to all speakers in database
%       .confidence       - confidence score (0-1)
%
% USAGE:
%   % Load database
%   load('speaker_database.mat', 'database');
%   
%   % Test with Euclidean distance
%   results = test_speaker_recognition(database, 'data/test', 'euclidean');
%   
%   % Display accuracy
%   accuracy = sum([results.correct]) / length(results) * 100;
%   fprintf('Accuracy: %.2f%%\n', accuracy);

    if nargin < 3
        distance_metric = 'euclidean';
    end
    
    fprintf('\n========================================\n');
    fprintf('Testing Speaker Recognition\n');
    fprintf('Distance Metric: %s\n', distance_metric);
    fprintf('========================================\n\n');
    
    % Get all test files
    test_files = dir(fullfile(test_folder, '*.wav'));
    num_tests = length(test_files);
    
    if num_tests == 0
        error('No .wav files found in %s', test_folder);
    end
    
    fprintf('Found %d test files\n\n', num_tests);
    
    % Initialize results
    results = struct('test_file', {}, 'true_speaker', {}, ...
                    'predicted_speaker', {}, 'correct', {}, ...
                    'distances', {}, 'confidence', {});
    
    % Process each test file
    for i = 1:num_tests
        fprintf('[%d/%d] Testing: %s\n', i, num_tests, test_files(i).name);
        
        % Read test audio
        file_path = fullfile(test_folder, test_files(i).name);
        [audio, fs] = audioread(file_path);
        
        % Convert stereo to mono if needed
        if size(audio, 2) > 1
            audio = mean(audio, 2);
        end
        
        % Extract MFCC features
        fprintf('   - Extracting MFCC features...\n');
        test_features = mfcc(audio, fs, false);
        test_mean = mean(test_features, 1);
        
        % Compute distance to each speaker in database
        fprintf('   - Computing distances to all speakers...\n');
        num_speakers = length(speaker_database);
        distances = zeros(num_speakers, 1);
        
        for j = 1:num_speakers
            distances(j) = compute_distance(test_mean, ...
                                           speaker_database(j).mean_vector, ...
                                           speaker_database(j).cov_matrix, ...
                                           distance_metric);
        end
        
        % Find closest match (minimum distance)
        [min_distance, predicted_idx] = min(distances);
        predicted_speaker = speaker_database(predicted_idx).speaker_id;
        
        % Extract true speaker ID from filename
        [~, true_speaker, ~] = fileparts(test_files(i).name);
        
        % Check if prediction is correct
        is_correct = strcmp(predicted_speaker, true_speaker);
        
        % Compute confidence (inverse of normalized distance)
        % Higher confidence when distance is smaller
        normalized_distances = distances / sum(distances);
        confidence = 1 - normalized_distances(predicted_idx);
        
        % Store results
        results(i).test_file = test_files(i).name;
        results(i).true_speaker = true_speaker;
        results(i).predicted_speaker = predicted_speaker;
        results(i).correct = is_correct;
        results(i).distances = distances;
        results(i).confidence = confidence;
        
        % Display result
        if is_correct
            fprintf('   ✓ CORRECT: Predicted=%s, True=%s (Distance=%.4f, Confidence=%.2f%%)\n\n', ...
                    predicted_speaker, true_speaker, min_distance, confidence*100);
        else
            fprintf('   ✗ WRONG: Predicted=%s, True=%s (Distance=%.4f, Confidence=%.2f%%)\n\n', ...
                    predicted_speaker, true_speaker, min_distance, confidence*100);
        end
    end
    
    % Calculate and display overall accuracy
    accuracy = sum([results.correct]) / num_tests * 100;
    
    fprintf('========================================\n');
    fprintf('Testing Complete!\n');
    fprintf('Accuracy: %.2f%% (%d/%d correct)\n', accuracy, sum([results.correct]), num_tests);
    fprintf('========================================\n\n');
end


function distance = compute_distance(test_vector, ref_vector, cov_matrix, metric)
% COMPUTE_DISTANCE - Calculate distance between test and reference vectors
%
% INPUTS:
%   test_vector - test feature vector (1 × D)
%   ref_vector  - reference feature vector (1 × D)
%   cov_matrix  - covariance matrix (D × D) - used for Mahalanobis
%   metric      - distance metric ('euclidean', 'cosine', 'mahalanobis')
%
% OUTPUTS:
%   distance - computed distance value

    switch lower(metric)
        case 'euclidean'
            % Euclidean distance: sqrt(sum((x - y)^2))
            distance = sqrt(sum((test_vector - ref_vector).^2));
            
        case 'cosine'
            % Cosine distance: 1 - (x·y) / (||x|| ||y||)
            dot_product = sum(test_vector .* ref_vector);
            norm_test = sqrt(sum(test_vector.^2));
            norm_ref = sqrt(sum(ref_vector.^2));
            cosine_similarity = dot_product / (norm_test * norm_ref);
            distance = 1 - cosine_similarity;
            
        case 'mahalanobis'
            % Mahalanobis distance: sqrt((x-y)' * inv(Σ) * (x-y))
            diff = test_vector - ref_vector;
            try
                distance = sqrt(diff * (cov_matrix \ diff'));
            catch
                % Fallback to Euclidean if covariance matrix is singular
                warning('Singular covariance matrix, using Euclidean distance');
                distance = sqrt(sum(diff.^2));
            end
            
        otherwise
            error('Unknown distance metric: %s', metric);
    end
end
