function coeffs = mfcc(signal, fs)
% MFCC - Extract Mel-Frequency Cepstral Coefficients from speech
%
% This is the MAIN function that orchestrates the entire MFCC pipeline.
% It calls 8 helper functions in sequence to transform raw audio into
% MFCC features suitable for speaker recognition.
%
% INPUTS:
%   signal - input audio waveform (column vector or row vector)
%   fs     - sampling frequency in Hz (e.g., 8000, 16000, 22050, 44100)
%
% OUTPUT:
%   coeffs - MFCC matrix
%            Default: (num_frames × 13) — each ROW is one frame
%            Alternative: (13 × num_frames) — each COLUMN is one frame
%            (see TRANSPOSE section at the end of this file)
%
% PIPELINE:
%   1. Pre-emphasis       → boost high frequencies
%   2. Frame blocking     → divide into overlapping segments
%   3. Windowing          → apply Hamming window
%   4. FFT                → time domain → frequency domain
%   5. Power spectrum     → compute energy at each frequency
%   6. Mel filterbank     → perceptual frequency warping
%   7. Logarithm          → compress dynamic range
%   8. DCT                → decorrelate and compress
%
% USAGE:
%   [audio, fs] = audioread('speech.wav');
%   mfcc_features = mfcc(audio, fs);
%
% EXAMPLE (Complete workflow):
%   % Load speech
%   [audio, fs] = audioread('S1.wav');
%   
%   % Extract MFCC
%   coeffs = mfcc(audio, fs);
%   
%   % Display info
%   fprintf('%d frames × %d coefficients\n', size(coeffs,1), size(coeffs,2));
%   
%   % Visualize
%   figure;
%   imagesc(coeffs'); axis xy; colorbar; colormap('jet');
%   xlabel('Frame'); ylabel('MFCC Coefficient');
%   title('MFCC Features');
%
% PARAMETERS (adjust as needed for your project):
%   alpha        = 0.97     Pre-emphasis coefficient
%   frame_length = 256      Frame size in samples (~16 ms at 16 kHz)
%   hop_size     = 100      Frame shift (~6 ms at 16 kHz, 61% overlap)
%   nfft         = 512      FFT size (zero-pads to this length)
%   num_filters  = 26       Number of mel filterbank filters
%   num_coeffs   = 13       Number of MFCC coefficients to extract
%
% REQUIREMENTS:
%   This function requires these helper functions in the same directory:
%   - preemphasis.m
%   - frame_signal.m
%   - apply_window.m
%   - compute_power_spectrum.m
%   - apply_mel_filterbank.m
%   - apply_log.m
%   - apply_dct.m
%   
%   Plus the provided function:
%   - melfb.m (creates mel filterbank)
%
% NOTES:
%   - All parameters are set as constants in this file (see below).
%     You can make them function arguments if you need flexibility.
%   - The output orientation (rows vs columns) can be changed at the
%     end — see the TRANSPOSE section.
%   - This implementation assumes melfb() signature is:
%     filterbank = melfb(num_filters, nfft, fs)
%     If your melfb.m is different, edit apply_mel_filterbank.m

% =========================================================================
% STEP 0: INPUT VALIDATION
% =========================================================================
if nargin < 2
    error('MFCC:NotEnoughInputs', ...
          ['MFCC requires 2 input arguments: mfcc(signal, fs)\n\n' ...
           'USAGE:\n' ...
           '  [audio, fs] = audioread(''speech.wav'');\n' ...
           '  coeffs = mfcc(audio, fs);\n\n' ...
           'Type ''help mfcc'' for more information.']);
end

% =========================================================================
% STEP 0.5: CONFIGURE PARAMETERS
% =========================================================================
% These are the standard values. Adjust if your project requires different settings.

alpha        = 0.97;    % Pre-emphasis coefficient (0.95-0.97 typical)
frame_length = 256;     % Samples per frame (20-30 ms typical)
                        % At fs=16kHz: 256 samples = 16 ms
                        % At fs=8kHz:  256 samples = 32 ms
hop_size     = 100;     % Frame shift in samples (10 ms typical)
                        % At fs=16kHz: 100 samples = 6.25 ms
                        % Overlap = frame_length - hop_size = 156 samples
nfft         = 512;     % FFT size (power of 2, >= frame_length)
num_filters  = 26;      % Mel filterbank filters (20-40 typical)
num_coeffs   = 13;      % MFCC coefficients to keep (12-13 standard)

% NEW OPTIONS:
drop_c0      = false;   % Set to true to drop the first coefficient (c0/energy)
                        % c0 is loudness-dependent and may not carry
                        % speaker-specific information. Some systems drop it.
add_deltas   = false;   % Set to true to add delta and delta-delta features
                        % This extends 13 MFCCs to 39 features (13+13+13)
delta_N      = 2;       % Window size for delta computation (frames on each side)

% =========================================================================
% STEP 0.5: INPUT VALIDATION AND PREPROCESSING
% =========================================================================
% Ensure signal is a column vector
if isrow(signal)
    signal = signal(:);
end

% Check signal length
if length(signal) < frame_length
    error('Signal too short! Need at least %d samples, got %d.', ...
          frame_length, length(signal));
end

% Optional: Remove DC offset (mean)
% Uncomment if your audio has a DC component:
% signal = signal - mean(signal);

% =========================================================================
% STEP 1: PRE-EMPHASIS
% =========================================================================
% Boost high frequencies to balance the spectrum
emphasized = preemphasis(signal, alpha);

% =========================================================================
% STEP 2: FRAME BLOCKING
% =========================================================================
% Divide signal into overlapping frames
% Output: (num_frames × frame_length) matrix, each row = one frame
frames = frame_signal(emphasized, frame_length, hop_size);

% =========================================================================
% STEP 3: WINDOWING
% =========================================================================
% Apply Hamming window to each frame to reduce spectral leakage
% Output: same size as frames
windowed_frames = apply_window(frames);

% =========================================================================
% STEP 4 & 5: FFT + POWER SPECTRUM
% =========================================================================
% Compute FFT and then power spectrum (|FFT|^2)
% Output: (num_frames × (nfft/2 + 1)) matrix
power_spectrum = compute_power_spectrum(windowed_frames, nfft);

% =========================================================================
% STEP 6: MEL FILTERBANK
% =========================================================================
% Apply mel-spaced triangular filterbank
% Uses the provided melfb.m function
% Output: (num_frames × num_filters) matrix
mel_energies = apply_mel_filterbank(power_spectrum, fs, nfft, num_filters);

% =========================================================================
% STEP 7: LOGARITHM
% =========================================================================
% Take log to compress dynamic range and match human perception
% Output: same size as mel_energies
log_mel = apply_log(mel_energies);

% =========================================================================
% STEP 8: DCT
% =========================================================================
% Apply Discrete Cosine Transform and keep first num_coeffs
% Output: (num_frames × num_coeffs) matrix by default
coeffs = apply_dct(log_mel, num_coeffs);

% =========================================================================
% STEP 8.5: OPTIONAL - DROP C0 (ENERGY COEFFICIENT)
% =========================================================================
% The first coefficient (c0) is proportional to log-energy/loudness.
% Some systems drop it because it's volume-dependent, not speaker-dependent.
if drop_c0
    coeffs = coeffs(:, 2:end);  % Remove first column (c0)
    % Now we have (num_frames × num_coeffs-1)
end

% =========================================================================
% STEP 9: OPTIONAL - ADD DELTA AND DELTA-DELTA FEATURES
% =========================================================================
% Delta features capture temporal dynamics (how MFCCs change over time).
% Delta-delta features capture acceleration (second derivative).
% Standard: 13 MFCC + 13 delta + 13 delta-delta = 39 features
if add_deltas
    delta_coeffs = compute_delta(coeffs, delta_N);       % First derivative
    delta_delta_coeffs = compute_delta(delta_coeffs, delta_N);  % Second derivative
    coeffs = [coeffs, delta_coeffs, delta_delta_coeffs];  % Concatenate
    % Now we have (num_frames × 3*num_coeffs) or (num_frames × 3*(num_coeffs-1)) if drop_c0
end

% =========================================================================
% TRANSPOSE (IF NEEDED)
% =========================================================================
% By default, this function returns (num_frames × num_coeffs).
% Each ROW is one frame's MFCC vector.
%
% If your train.m expects (num_coeffs × num_frames) format
% (each COLUMN is one frame), uncomment this line:
%
% coeffs = coeffs';
%
% To check what your project expects:
% 1. Open train.m
% 2. Look for how it uses the MFCC output
% 3. If it indexes like mfcc(:, frame_idx), you need columns (transpose)
% 4. If it indexes like mfcc(frame_idx, :), you need rows (don't transpose)

% =========================================================================
% DEBUGGING OUTPUT (uncomment to see pipeline details)
% =========================================================================
% fprintf('\n=== MFCC EXTRACTION COMPLETE ===\n');
% fprintf('Input signal:      %d samples (%.2f seconds at %d Hz)\n', ...
%         length(signal), length(signal)/fs, fs);
% fprintf('After pre-emphasis: %d samples\n', length(emphasized));
% fprintf('Frames created:    %d frames\n', size(frames,1));
% fprintf('Frame parameters:  %d samples/frame, %d hop, %d overlap (%.1f%%)\n', ...
%         frame_length, hop_size, frame_length-hop_size, ...
%         (frame_length-hop_size)/frame_length*100);
% fprintf('FFT size:          %d (%.1f Hz resolution)\n', nfft, fs/nfft);
% fprintf('Mel filters:       %d\n', num_filters);
% fprintf('MFCC coeffs kept:  %d\n', num_coeffs);
% fprintf('Output size:       %d × %d\n', size(coeffs,1), size(coeffs,2));
% fprintf('MFCC range:        [%.2f, %.2f]\n', min(coeffs(:)), max(coeffs(:)));
% fprintf('MFCC mean:         %.4f\n', mean(coeffs(:)));
% fprintf('MFCC std:          %.4f\n', std(coeffs(:)));
% fprintf('================================\n\n');

end

% =========================================================================
% FUNCTION COMPLETE
% =========================================================================
% You now have a complete MFCC implementation!
%
% NEXT STEPS:
% 1. Test this function on one of your training files (S1.wav)
% 2. Visualize the output to make sure it looks reasonable
% 3. Run it on all 8 training files
% 4. Use the output in your VQ/LBG algorithm (vqlbg.m)
% 5. Integrate with train.m and test.m
%
% TROUBLESHOOTING:
% - If you get dimension errors: check the transpose section above
% - If you get NaN or Inf: check the eps value in apply_log.m
% - If MFCC values look too large/small: check the log step
% - If output is all zeros: check that audio file loaded correctly
%
% PERFORMANCE:
% On a modern computer, this should process:
% - 1 second of audio in ~0.01-0.05 seconds
% - Your 8 training files (each ~1 sec) in under 1 second total
%
% =========================================================================
