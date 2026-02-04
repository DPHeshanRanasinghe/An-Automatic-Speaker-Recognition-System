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
num_frames = floor((N - frame_length) / hop_size) + 1;

if num_frames < 1
    error('Signal too short for even 1 frame. Need at least %d samples.', ...
          frame_length);
end

frames = zeros(num_frames, frame_length);

% Extract frames
for i = 1:num_frames
    % Calculate starting index for this frame
    start_idx = (i - 1) * hop_size + 1;
    end_idx   = start_idx + frame_length - 1;
    
    % Extract frame
    frames(i, :) = signal(start_idx : end_idx);
end

fprintf('Frame blocking complete:\n');
fprintf('  Signal length: %d samples\n', N);
fprintf('  Frame length:  %d samples (%.2f ms at 16kHz)\n',frame_length, frame_length/16000*1000);
fprintf('  Hop size:      %d samples (%.2f ms at 16kHz)\n',hop_size, hop_size/16000*1000);
fprintf('  Overlap:       %d samples (%.1f%%)\n', frame_length - hop_size, (frame_length-hop_size)/frame_length*100);
fprintf('  Num frames:    %d\n', num_frames);
fprintf('  Output size:   %d × %d\n', size(frames,1), size(frames,2));

end

