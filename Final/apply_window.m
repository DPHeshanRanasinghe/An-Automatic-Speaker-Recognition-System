function windowed_frames = apply_window(frames)

[frame_length, ~] = size(frames);

window = hamming(frame_length, 'periodic');
windowed_frames = frames .* window;

end