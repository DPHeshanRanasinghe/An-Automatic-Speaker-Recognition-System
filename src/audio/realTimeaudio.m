function sys = realTimeAudio(fs, screen)
% realTimeAudio
% Real-time microphone waveform display
%
% Inputs:
%   fs     - Sampling frequency (Hz), default 16000
%   screen - Time window to display (seconds), default 5
%
% Output:
%   sys.recorder - audiorecorder object
%   sys.clock    - timer object

% -------------------------------
% Default arguments
% -------------------------------
if nargin < 1
    fs = 16000;
end
if nargin < 2
    screen = 5;
end

% -------------------------------
% Create audio recorder
% -------------------------------
recObj = audiorecorder(fs, 16, 1); % 16-bit, mono

% -------------------------------
% Plot initialization
% -------------------------------
bufferLength = fs * screen;
audioBuffer = zeros(bufferLength,1);

figure('Name','Real-Time Audio');
hPlot = plot(audioBuffer);
ylim([-1 1]);
xlabel('Samples');
ylabel('Amplitude');
title('Microphone Signal');
grid on;

% -------------------------------
% Timer for real-time update
% -------------------------------
t = timer( ...
    'ExecutionMode','fixedRate', ...
    'Period',0.05, ...
    'TimerFcn',@updatePlot);

% -------------------------------
% Start recording
% -------------------------------
record(recObj);
start(t);

% -------------------------------
% Return handles
% -------------------------------
sys.recorder = recObj;
sys.clock    = t;

% ===============================
% Nested update function
% ===============================
    function updatePlot(~,~)
        if recObj.TotalSamples == 0
            return;
        end

        data = getaudiodata(recObj);

        if length(data) > bufferLength
            audioBuffer = data(end-bufferLength+1:end);
        else
            audioBuffer = zeros(bufferLength,1);
            audioBuffer(end-length(data)+1:end) = data;
        end

        set(hPlot,'YData',audioBuffer);
        drawnow limitrate;
    end
end

