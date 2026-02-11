function filterbank = melfb(num_filters, nfft, fs)
% MELFB - Create a mel-spaced triangular filterbank
%
% This function generates a bank of triangular bandpass filters spaced
% uniformly on the mel frequency scale. Used in MFCC computation.
%
% INPUTS:
%   num_filters - number of mel filters (typically 20-40, common: 26)
%   nfft        - FFT size (e.g., 512)
%   fs          - sampling frequency in Hz (e.g., 16000)
%
% OUTPUT:
%   filterbank - matrix of size (num_filters × nfft/2+1)
%                Each row is one triangular filter
%                Values are non-negative weights (0 to 1)
%
% MATH:
%   Mel scale conversion:
%     mel(f) = 2595 * log10(1 + f/700)
%     f(mel) = 700 * (10^(mel/2595) - 1)
%
%   Filters are triangular:
%     - Rising slope from f[i-1] to f[i]
%     - Peak (value = 1.0) at f[i]
%     - Falling slope from f[i] to f[i+1]
%
% USAGE:
%   filterbank = melfb(26, 512, 16000);
%   
%   % Visualize the filterbank
%   figure;
%   plot((0:256) * 16000/512, filterbank');
%   xlabel('Frequency (Hz)'); ylabel('Weight');
%   title('Mel Filterbank (26 filters)');
%
% EXAMPLE:
%   % Apply to power spectrum
%   filterbank = melfb(26, 512, 16000);
%   mel_energies = power_spectrum * filterbank';

% =========================================================================
% Input validation
% =========================================================================
if num_filters < 1
    error('num_filters must be >= 1');
end

if nfft < 2
    error('nfft must be >= 2');
end

if fs <= 0
    error('Sampling frequency must be positive');
end

% =========================================================================
% Define frequency range
% =========================================================================
% Minimum frequency: 0 Hz (or sometimes 20-80 Hz to exclude DC noise)
% Maximum frequency: Nyquist frequency (fs/2)
f_min = 0;       % Lower frequency bound (Hz)
f_max = fs / 2;  % Upper frequency bound (Nyquist)

% =========================================================================
% Convert frequency bounds to mel scale
% =========================================================================
mel_min = hz_to_mel(f_min);
mel_max = hz_to_mel(f_max);

% =========================================================================
% Create mel-spaced center frequencies
% =========================================================================
% We need (num_filters + 2) points:
%   - Point 1: left edge of first filter (at mel_min)
%   - Points 2 to num_filters+1: center frequencies of each filter
%   - Point num_filters+2: right edge of last filter (at mel_max)

mel_points = linspace(mel_min, mel_max, num_filters + 2);

% Convert mel points back to Hz
hz_points = mel_to_hz(mel_points);

% =========================================================================
% Convert Hz to FFT bin indices
% =========================================================================
% Frequency of bin k: f[k] = k * fs / nfft
% Bin index for frequency f: k = round(f * nfft / fs)

num_bins = nfft / 2 + 1;  % Number of positive frequency bins
bin_points = round(hz_points * nfft / fs) + 1;  % +1 for MATLAB 1-indexing

% Ensure bin indices are within valid range
bin_points = max(1, min(num_bins, bin_points));

% =========================================================================
% Create filterbank matrix
% =========================================================================
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

% =========================================================================
% Optional: Normalize filters (area normalization)
% =========================================================================
% Uncomment to normalize each filter to have unit area (energy normalization)
% This makes the filterbank energy-preserving
%
% for m = 1:num_filters
%     area = sum(filterbank(m, :));
%     if area > 0
%         filterbank(m, :) = filterbank(m, :) / area;
%     end
% end

% =========================================================================
% DEBUGGING / VERIFICATION (uncomment to check)
% =========================================================================
% fprintf('Mel filterbank created:\n');
% fprintf('  Num filters:    %d\n', num_filters);
% fprintf('  NFFT:           %d\n', nfft);
% fprintf('  Sampling rate:  %d Hz\n', fs);
% fprintf('  Freq range:     %.1f - %.1f Hz\n', f_min, f_max);
% fprintf('  Mel range:      %.1f - %.1f mel\n', mel_min, mel_max);
% fprintf('  Output size:    %d × %d\n', size(filterbank,1), size(filterbank,2));
% fprintf('  Non-zero bins per filter: %d to %d\n', ...
%         min(sum(filterbank > 0, 2)), max(sum(filterbank > 0, 2)));

end

% =========================================================================
% HELPER FUNCTIONS
% =========================================================================

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

% =========================================================================
% TECHNICAL NOTES:
% =========================================================================
% 1. Why mel scale?
%    Human perception of pitch is nonlinear. We're more sensitive to
%    differences at low frequencies than high frequencies. The mel scale
%    approximates this: 1000 mel ≈ 1000 Hz, but 2000 mel ≈ 3400 Hz.
%
% 2. Why triangular filters?
%    Triangular filters are simple, efficient, and provide smooth
%    interpolation between adjacent frequency bands. They overlap
%    so that each frequency bin contributes to at most 2 filters.
%
% 3. Filter width:
%    Filters are narrower at low frequencies (more frequency resolution
%    where humans are sensitive) and wider at high frequencies (less
%    resolution where humans are less sensitive).
%
% 4. Bin indices:
%    We map continuous Hz frequencies to discrete FFT bin indices.
%    Rounding can cause multiple filters to share the same peak bin
%    at high frequencies where filters are wide.
%
% 5. Alternative formulas:
%    Some implementations use different mel scale formulas:
%    - O'Shaughnessy: mel = 2595 * log10(1 + f/700)  [used here]
%    - Slaney (HTK): mel = 1127 * ln(1 + f/700)     [natural log]
%    The difference is just a scale factor (2595/1127 ≈ 2.303 ≈ ln(10))
%
% 6. Frequency bounds:
%    - f_min = 0 Hz: Standard choice
%    - f_min = 20-80 Hz: Sometimes used to exclude DC/low-freq noise
%    - f_max = fs/2: Nyquist (must not exceed this)
%    - f_max = 8000 Hz: Sometimes capped for telephone-quality speech
%
% =========================================================================
