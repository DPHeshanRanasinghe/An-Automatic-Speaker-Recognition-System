function power_spectrum = compute_power_spectrum(windowed_frames, nfft)

[num_frames, frame_length] = size(windowed_frames);

if nfft < frame_length
    error('NFFT (%d) must be >= frame_length (%d)', nfft, frame_length);
end

if ~(nfft > 0 && mod(log2(nfft), 1) == 0)
    warning('NFFT=%d is not a power of 2. FFT will be slower.', nfft);
end

num_bins = nfft/2 + 1;  % e.g., for nfft=512 → 257 bins

power_spectrum = zeros(num_frames, num_bins);

for i = 1:num_frames
    % Take FFT of this frame
    % If frame_length < nfft, MATLAB automatically zero-pads
    fft_result = fft(windowed_frames(i, :), nfft);
    
    % Keep only positive frequencies (bins 1 to nfft/2+1)
    fft_positive = fft_result(1:num_bins);
    
    % Compute power spectrum: |X|² = X * conj(X)
    power_spectrum(i, :) = abs(fft_positive).^2;
    
    % Alternative (equivalent but slightly slower):
    % power_spectrum(i, :) = real(fft_positive).^2 + imag(fft_positive).^2;
end

power_spectrum = power_spectrum / nfft;

end

