% RUN_DEMO - Simple script to run the demo from any directory
%
% This ensures the working directory is set correctly before running

% Get the directory where this script is located
script_dir = fileparts(mfilename('fullpath'));

% Change to that directory
cd(script_dir);

% Add it to the path
addpath(script_dir);

% Verify key functions are accessible
if exist('mfcc.m', 'file') == 2
    fprintf('✓ mfcc.m found\n');
else
    error('✗ mfcc.m not found! Check your directory.');
end

fprintf('✓ All files accessible\n\n');

% Now run the demo
demo_mfcc;
