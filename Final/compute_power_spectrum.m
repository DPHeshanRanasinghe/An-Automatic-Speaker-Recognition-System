function power_spectrum = compute_power_spectrum(windowed_frames, nfft)

[frame_length, ~] = size(windowed_frames);

if nfft < frame_length
    error('NFFT (%d) must be >= frame_length (%d)', nfft, frame_length);
end

if nfft <= 0 || nfft ~= floor(nfft)
    error('NFFT must be a positive integer');
end

if mod(log2(nfft), 1) ~= 0
    warning('NFFT=%d is not a power of 2. FFT will be slower.', nfft);
end

num_bins = floor(nfft / 2) + 1;

fft_result = fft(windowed_frames, nfft, 1);
fft_positive = fft_result(1:num_bins, :);

power_spectrum = abs(fft_positive).^2 / nfft;

end