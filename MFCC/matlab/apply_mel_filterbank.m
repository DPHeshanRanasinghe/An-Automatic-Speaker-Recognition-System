function mel_energies = apply_mel_filterbank(power_spectrum, fs, nfft, num_filters)
% APPLY_MEL_FILTERBANK - Apply mel filterbank to power spectrum
%
% This is Step 6 of the MFCC pipeline. The mel filterbank converts the
% linear frequency scale to the mel scale, which models human perception.
% Uses the provided melfb.m function to create triangular filters.
%
% INPUTS:
%   power_spectrum - power spectrum matrix (num_frames × num_bins)
%   fs             - sampling frequency (Hz), e.g., 16000
%   nfft           - FFT size used to compute power_spectrum
%   num_filters    - number of mel filters (typically 20-40, common: 26)
%
% OUTPUT:
%   mel_energies - mel filterbank energies (num_frames × num_filters)
%
% MATH:
%   The mel scale: mel(f) = 2595 * log₁₀(1 + f/700)
%   
%   We create num_filters triangular bandpass filters spaced uniformly
%   on the mel scale. Each filter output is the weighted sum of power
%   spectrum bins within its passband.
%   
%   Matrix form: E = P * H'
%   where P is power_spectrum (frames × bins)
%         H is filterbank from melfb() (filters × bins)
%         E is mel_energies (frames × filters)
%
% USAGE:
%   mel_energies = apply_mel_filterbank(power, 16000, 512, 26);
%
% EXAMPLE:
%   [audio, fs] = audioread('speech.wav');
%   emp = preemphasis(audio);
%   frames = frame_signal(emp, 256, 100);
%   windowed = apply_window(frames);
%   power = compute_power_spectrum(windowed, 512);
%   mel_energies = apply_mel_filterbank(power, fs, 512, 26);
%   
%   fprintf('Mel energies size: %d frames × %d mel bands\n', ...
%           size(mel_energies,1), size(mel_energies,2));
%   
%   % Visualize mel filterbank energies over time
%   figure;
%   imagesc(mel_energies'); axis xy; colorbar; colormap('jet');
%   xlabel('Frame'); ylabel('Mel Filter');
%   title('Mel Filterbank Energies');

% =========================================================================
% Get dimensions
% =========================================================================
[num_frames, num_bins] = size(power_spectrum);

% =========================================================================
% Validate num_bins matches nfft
% =========================================================================
expected_bins = nfft/2 + 1;
if num_bins ~= expected_bins
    error(['Power spectrum has %d bins but expected %d bins for nfft=%d.\n' ...
           'Make sure you used the same nfft in compute_power_spectrum().'], ...
          num_bins, expected_bins, nfft);
end

% =========================================================================
% Create mel filterbank using the provided melfb.m
% =========================================================================
% IMPORTANT: Check the signature of YOUR melfb.m file!
% Different implementations have different parameter orders:
%
% Common signatures:
%   filterbank = melfb(num_filters, nfft, fs)           ← Most common
%   filterbank = melfb(num_filters, fs, nfft)
%   filterbank = melfb(num_filters, nfft, fs, f_low, f_high)
%
% The output is typically a matrix of size (num_filters × num_bins)
% where each row is one triangular filter.

% ASSUMPTION: We assume the signature is melfb(num_filters, nfft, fs)
% If your melfb.m has a different signature, change this line:
filterbank = melfb(num_filters, nfft, fs);

% =========================================================================
% Validate filterbank dimensions
% =========================================================================
[fb_rows, fb_cols] = size(filterbank);

if fb_rows ~= num_filters
    error('Filterbank has %d rows but expected %d (num_filters).', ...
          fb_rows, num_filters);
end

if fb_cols ~= num_bins
    error('Filterbank has %d columns but power_spectrum has %d bins.', ...
          fb_cols, num_bins);
end

% =========================================================================
% Apply filterbank via matrix multiplication
% =========================================================================
% We want: each frame's power spectrum → mel energies
% 
% power_spectrum: (num_frames × num_bins)   e.g., (100 × 257)
% filterbank:     (num_filters × num_bins)  e.g., (26 × 257)
% 
% To multiply: (100 × 257) · (257 × 26) = (100 × 26)
% So we need filterbank transposed!

mel_energies = power_spectrum * filterbank';
% Result: (num_frames × num_filters)

% =========================================================================
% DEBUGGING / VERIFICATION (uncomment to check)
% =========================================================================
% fprintf('Mel filterbank applied:\n');
% fprintf('  Num frames:     %d\n', num_frames);
% fprintf('  Power bins:     %d\n', num_bins);
% fprintf('  Num filters:    %d\n', num_filters);
% fprintf('  Filterbank size: %d × %d\n', fb_rows, fb_cols);
% fprintf('  Output size:    %d × %d\n', size(mel_energies,1), size(mel_energies,2));
% fprintf('  Energy range:   [%.2e, %.2e]\n', min(mel_energies(:)), max(mel_energies(:)));
% 
% % Check for any zero or negative energies
% if any(mel_energies(:) <= 0)
%     warning('%d mel energy values are ≤ 0. This may cause issues in log step.', ...
%             sum(mel_energies(:) <= 0));
% end

end

% =========================================================================
% TECHNICAL NOTES:
% =========================================================================
% 1. What is the mel scale?
%    The mel scale is a perceptual frequency scale based on how humans
%    perceive pitch. Equal distances on the mel scale correspond to
%    equal perceived differences in pitch.
%    
%    Conversion formulas:
%       mel(f) = 2595 * log₁₀(1 + f/700)
%       f(mel) = 700 * (10^(mel/2595) - 1)
%    
%    At low frequencies (f < 1000 Hz), the relationship is approximately
%    linear (1 mel ≈ 1 Hz). At high frequencies, it's logarithmic.
%    
%    Examples:
%       f = 0 Hz     → mel = 0
%       f = 1000 Hz  → mel ≈ 1000
%       f = 4000 Hz  → mel ≈ 2500
%       f = 8000 Hz  → mel ≈ 2840
%    
%    This matches psychoacoustic experiments: we're good at distinguishing
%    200 Hz from 250 Hz (50 Hz difference), but we need a bigger
%    difference to distinguish 4000 Hz from 4050 Hz.
%
% 2. Triangular filter shape:
%    Each mel filter is a triangle in the frequency domain:
%    - Left edge at frequency f[i-1]
%    - Peak (value = 1.0) at frequency f[i]
%    - Right edge at frequency f[i+1]
%    - Zero everywhere else
%    
%    The filters overlap: each frequency bin contributes to at most
%    2 filters (the rising slope of one and the falling slope of the next).
%    
%    This ensures smooth coverage of the spectrum — no gaps, no double-
%    counting, just a gentle redistribution of energy from linear frequency
%    bins to perceptually-spaced mel bins.
%
% 3. Why 26 filters?
%    This is a convention from early speech recognition work. The number
%    can range from 20 to 40:
%    - Fewer filters (20): faster, less detail
%    - More filters (40): more detail, more computation, risk of overfitting
%    
%    26 is a good balance. It's enough to capture formant structure
%    (typically 3-5 formants in vowels) with some redundancy.
%
% 4. Matrix multiplication explanation:
%    Each row of power_spectrum is one frame (257 frequency bins).
%    Each row of filterbank is one triangular filter (257 weights).
%    
%    The dot product of one frame with one filter gives the energy
%    in that mel band for that frame. We do this for all frames and
%    all filters via matrix multiplication:
%    
%    mel_energies[frame_i, filter_j] = Σ_k power[frame_i, k] * filterbank[filter_j, k]
%    
%    In matrix form: mel_energies = power_spectrum * filterbank'
%
% 5. Why transpose the filterbank?
%    MATLAB's matrix multiply (A * B) requires:
%    - A is (m × n)
%    - B is (n × p)
%    - Result is (m × p)
%    
%    We have:
%    - power_spectrum: (num_frames × num_bins)
%    - filterbank: (num_filters × num_bins)
%    
%    To match dimensions, we transpose filterbank:
%    - filterbank': (num_bins × num_filters)
%    
%    Then: (num_frames × num_bins) · (num_bins × num_filters)
%          = (num_frames × num_filters) ✓
%
% 6. Physical meaning:
%    mel_energies[i, j] = total energy in frame i within mel band j
%    
%    This is a compressed representation: we've gone from 257 frequency
%    bins down to 26 mel bands, capturing the perceptually-relevant
%    spectral envelope while discarding fine detail.
%
% 7. Relation to human hearing:
%    The cochlea (inner ear) acts as a bank of overlapping bandpass
%    filters with approximately logarithmic spacing. The mel filterbank
%    is a simplified model of this. MFCC features based on mel filtering
%    are easier for machine learning algorithms to work with than raw
%    spectra because they match how humans process sound.
%
% =========================================================================
