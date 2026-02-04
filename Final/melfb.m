function filterbank = melfb(num_filters, nfft, fs)
if num_filters < 1
    error('num_filters must be >= 1');
end

if nfft < 2
    error('nfft must be >= 2');
end

if fs <= 0
    error('Sampling frequency must be positive');
end

f_min = 0;       % Lower frequency bound (Hz)
f_max = fs / 2;  % Upper frequency bound (Nyquist)

mel_min = hz_to_mel(f_min);
mel_max = hz_to_mel(f_max);

mel_points = linspace(mel_min, mel_max, num_filters + 2);

% Convert mel points back to Hz
hz_points = mel_to_hz(mel_points);

num_bins = nfft / 2 + 1;  % Number of positive frequency bins
bin_points = round(hz_points * nfft / fs) + 1;  % +1 for MATLAB 1-indexing

% Ensure bin indices are within valid range
bin_points = max(1, min(num_bins, bin_points));

filterbank = zeros(num_filters, num_bins);

for m = 1:num_filters
    % Get the three bin indices for this filter
    % f[m-1], f[m], f[m+1] in 0-indexed terms
    % In MATLAB: bin_points(m), bin_points(m+1), bin_points(m+2)
    
    left_bin   = bin_points(m);      % Left edge
    center_bin = bin_points(m + 1);  % Center (peak)
    right_bin  = bin_points(m + 2);  % Right edge
    
    % Rising slope: from left_bin to center_bin
    for k = left_bin:center_bin
        if center_bin ~= left_bin  % Avoid division by zero
            filterbank(m, k) = (k - left_bin) / (center_bin - left_bin);
        end
    end
    
    % Falling slope: from center_bin to right_bin
    for k = center_bin:right_bin
        if right_bin ~= center_bin  % Avoid division by zero
            filterbank(m, k) = (right_bin - k) / (right_bin - center_bin);
        end
    end
end

end

function mel = hz_to_mel(hz)
% Convert frequency in Hz to mel scale
% Formula: mel = 2595 * log10(1 + f/700)
    mel = 2595 * log10(1 + hz / 700);
end

function hz = mel_to_hz(mel)
% Convert mel scale to frequency in Hz
% Formula: f = 700 * (10^(mel/2595) - 1)
    hz = 700 * (10.^(mel / 2595) - 1);
end
