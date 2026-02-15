function frames = frameSpeech(s, fs, frameLength_ms, frameShift_ms)
% frameSpeech
% Splits speech signal into overlapping, windowed frames
%
% Inputs:
%   s              - pre-processed speech signal
%   fs             - sampling frequency (Hz)
%   frameLength_ms - frame length in ms (e.g., 25)
%   frameShift_ms  - frame shift in ms (e.g., 10)
%
% Output:
%   frames         - matrix (each column is a frame)

% Ensure column vector
s = s(:);

% Convert ms to samples
frameLength = round(frameLength_ms * 1e-3 * fs);
frameShift  = round(frameShift_ms  * 1e-3 * fs);

signalLength = length(s);

% Number of frames
numFrames = floor((signalLength - frameLength) / frameShift) + 1;

% Pre-allocate
frames = zeros(frameLength, numFrames);

% Hamming window
win = hamming(frameLength);

% Frame extraction
for i = 1:numFrames
    startIdx = (i-1)*frameShift + 1;
    endIdx   = startIdx + frameLength - 1;
    frames(:,i) = s(startIdx:endIdx) .* win;
end

end
