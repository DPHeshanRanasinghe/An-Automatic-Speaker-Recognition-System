function frames = frame_signal(signal, frame_length, hop_size)
if isrow(signal)
    signal = signal(:);  % ensure column vector
end

N = length(signal);

if frame_length > N
    error('Frame length (%d) cannot be larger than signal length (%d)', ...
          frame_length, N);
end

if hop_size <= 0
    error('Hop size must be positive');
end

% Calculate number of frames
% We can extract frames as long as we have enough samples remaining
num_frames = floor((N - frame_length) / hop_size) + 1;

if num_frames < 1
    error('Signal too short for even 1 frame. Need at least %d samples.', ...
          frame_length);
end

% Pre-allocate output matrix
% Each row will be one frame
frames = zeros(num_frames, frame_length);


for i = 1:num_frames
    % Calculate starting index for this frame
    start_idx = (i - 1) * hop_size + 1;
    end_idx   = start_idx + frame_length - 1;
    
    % Extract frame
    frames(i, :) = signal(start_idx : end_idx);
end

% fprintf('Frame blocking complete:\n');
% fprintf('  Signal length: %d samples\n', N);
% fprintf('  Frame length:  %d samples (%.2f ms at 16kHz)\n', frame_length, frame_length/16000*1000);
% fprintf('  Hop size:      %d samples (%.2f ms at 16kHz)\n', hop_size, hop_size/16000*1000);
% fprintf('  Overlap:       %d samples (%.1f%%)\n', frame_length - hop_size, (frame_length-hop_size)/frame_length*100);
% fprintf('  Num frames:    %d\n', num_frames);
% fprintf('  Output size:   %d × %d\n', size(frames,1), size(frames,2));

end


% TECHNICAL NOTES:

% 1. Why overlap?
%    Overlapping frames ensures that every part of the signal is analyzed
%    in the "center" of some frame. Without overlap, information at frame
%    boundaries would be poorly represented (edge effects from windowing).
%    Typical overlap: 50% (hop = frame_length/2) to 75%.
%
% 2. Why 256 samples / 16 ms?
%    Speech phonemes (basic sound units) last about 20-50 ms. A 16-30 ms
%    window captures a single "snapshot" of a phoneme. If too long, you
%    average across multiple phonemes. If too short, frequency resolution
%    suffers (FFT resolution = fs/N).
%
% 3. Row vs column orientation:
%    This function returns frames as ROWS for convenience in MATLAB
%    (easier to loop, easier to apply operations). Some implementations
%    use columns. The orientation matters when you multiply with windows
%    and filterbanks later!
%
% 4. Last frame:
%    This implementation stops when there aren't enough samples left for
%    a full frame. Alternative: zero-pad the signal so the last frame
%    is complete. For speaker recognition this usually doesn't matter.
%
% 5. Alternative implementation using buffer():
%    MATLAB has a built-in buffer() function that can do this, but it's
%    less intuitive and the output format is different. This explicit
%    loop is clearer for learning.

