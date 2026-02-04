% EXTRACT_FEATURES - Batch extract MFCC features from all audio files
%
% This script processes all audio files in the data/train and data/test
% folders and extracts 39-dimensional MFCC features for each file.
%
% USAGE:
%   Run this script to extract features from all files
%
% OUTPUT:
%   Saves .mat files containing extracted features

clear; clc; close all;

% Change to the script's directory and add to path
script_dir = fileparts(mfilename('fullpath'));
cd(script_dir);
addpath(script_dir);

fprintf('\n');
fprintf('========================================\n');
fprintf('  MFCC FEATURE EXTRACTION - BATCH MODE\n');
fprintf('========================================\n\n');
fprintf('Working directory: %s\n\n', pwd);

% =========================================================================
% Configuration
% =========================================================================
train_folder = 'data/train';
test_folder = 'data/test';
output_folder = 'features';

% Create output folder if it doesn't exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
    fprintf('Created output folder: %s\n', output_folder);
end

% =========================================================================
% Process Training Files
% =========================================================================
fprintf('Processing TRAINING files...\n');
fprintf('----------------------------------------\n');

if exist(train_folder, 'dir')
    train_files = dir(fullfile(train_folder, '*.wav'));
    
    for i = 1:length(train_files)
        filepath = fullfile(train_folder, train_files(i).name);
        [~, filename, ~] = fileparts(train_files(i).name);
        
        fprintf('[%d/%d] Processing: %s\n', i, length(train_files), train_files(i).name);
        
        try
            % Extract features
            [features, mfcc_coeffs, delta, delta2] = mfcc(filepath, false);
            
            % Save to .mat file
            output_file = fullfile(output_folder, [filename '_features.mat']);
            save(output_file, 'features', 'mfcc_coeffs', 'delta', 'delta2', 'filepath');
            
            fprintf('  ✓ Extracted %d frames × 39 features\n', size(features, 1));
            fprintf('  ✓ Saved to: %s\n\n', output_file);
            
        catch ME
            fprintf('  ✗ ERROR: %s\n\n', ME.message);
        end
    end
else
    fprintf('  ⚠ Training folder not found: %s\n', train_folder);
end

% =========================================================================
% Process Test Files
% =========================================================================
fprintf('\nProcessing TEST files...\n');
fprintf('----------------------------------------\n');

if exist(test_folder, 'dir')
    test_files = dir(fullfile(test_folder, '*.wav'));
    
    for i = 1:length(test_files)
        filepath = fullfile(test_folder, test_files(i).name);
        [~, filename, ~] = fileparts(test_files(i).name);
        
        fprintf('[%d/%d] Processing: %s\n', i, length(test_files), test_files(i).name);
        
        try
            % Extract features
            [features, mfcc_coeffs, delta, delta2] = mfcc(filepath, false);
            
            % Save to .mat file
            output_file = fullfile(output_folder, [filename '_features.mat']);
            save(output_file, 'features', 'mfcc_coeffs', 'delta', 'delta2', 'filepath');
            
            fprintf('  ✓ Extracted %d frames × 39 features\n', size(features, 1));
            fprintf('  ✓ Saved to: %s\n\n', output_file);
            
        catch ME
            fprintf('  ✗ ERROR: %s\n\n', ME.message);
        end
    end
else
    fprintf('  ⚠ Test folder not found: %s\n', test_folder);
end

% =========================================================================
% Summary
% =========================================================================
fprintf('========================================\n');
fprintf('  FEATURE EXTRACTION COMPLETE\n');
fprintf('========================================\n');
fprintf('Features saved to: %s\n', output_folder);
fprintf('\nTo visualize a specific file:\n');
fprintf('  features = mfcc(''data/train/S1.wav'', true);\n\n');
