function emphasized = preemphasis(signal, alpha)
% PREEMPHASIS - Apply pre-emphasis filter to boost high frequencies
%
% This is Step 1 of the MFCC pipeline. Pre-emphasis balances the spectrum
% by boosting high frequencies that are naturally weaker in speech.
%
% INPUTS:
%   signal - input audio signal (column vector)
%   alpha  - pre-emphasis coefficient (default: 0.97)
%            Typical range: 0.95 to 0.97
%
% OUTPUT:
%   emphasized - filtered signal (same size as input)
%
% MATH:
%   This implements a first-order FIR high-pass filter:
%   y[n] = x[n] - alpha * x[n-1]
%
%   In the Z-domain: H(z) = 1 - alpha*z^(-1)
%
% USAGE:
%   emphasized = preemphasis(signal);        % uses alpha=0.97
%   emphasized = preemphasis(signal, 0.95);  % custom alpha
%
% EXAMPLE:
%   [audio, fs] = audioread('speech.wav');
%   emp = preemphasis(audio, 0.97);
%   
%   % Compare spectra
%   figure;
%   subplot(2,1,1); pwelch(audio, [], [], [], fs); title('Before');
%   subplot(2,1,2); pwelch(emp, [], [], [], fs); title('After');
%   % You should see high frequencies boosted!

% =========================================================================
% Handle input arguments
% =========================================================================
if nargin < 2
    alpha = 0.97;  % default value (standard in speech processing)
end

% Ensure signal is a column vector
if isrow(signal)
    signal = signal(:);
end

% =========================================================================
% Method 1: Using MATLAB's filter() function (RECOMMENDED - Fast & Clean)
% =========================================================================
% The filter() function implements the difference equation:
%   a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... - a(2)*y(n-1) - ...
%
% For pre-emphasis: y(n) = x(n) - alpha*x(n-1)
% So: b = [1, -alpha], a = 1

emphasized = filter([1 -alpha], 1, signal);

% =========================================================================
% Method 2: Manual implementation (for understanding)
% =========================================================================
% Uncomment this section if you want to see what's happening step-by-step:
%
% emphasized = zeros(size(signal));  % pre-allocate output
% emphasized(1) = signal(1);          % first sample unchanged
% 
% for n = 2:length(signal)
%     emphasized(n) = signal(n) - alpha * signal(n-1);
% end

% =========================================================================
% DEBUGGING / TESTING CODE (uncomment to verify)
% =========================================================================
% fprintf('Pre-emphasis applied:\n');
% fprintf('  Input samples: %d\n', length(signal));
% fprintf('  Alpha: %.4f\n', alpha);
% fprintf('  Output range: [%.4f, %.4f]\n', min(emphasized), max(emphasized));

end

% =========================================================================
% TECHNICAL NOTES:
% =========================================================================
% 1. Why pre-emphasis?
%    Speech signals have more energy at low frequencies due to the glottal
%    source. This creates an imbalanced spectrum. Pre-emphasis flattens
%    the spectrum so that the MFCC features capture both low and high
%    frequency information equally.
%
% 2. Why alpha = 0.97?
%    This value empirically provides good balance. The filter's magnitude
%    response at low frequencies is nearly 0, and at high frequencies
%    (Nyquist) it's about 2.0. This compensates for the ~6dB/octave
%    roll-off in natural speech spectra.
%
% 3. Filter stability:
%    This is an FIR filter (no feedback), so it's always stable.
%    All poles are at z=0.
%
% 4. Edge effects:
%    The first sample is not pre-emphasized (or only weakly) because
%    there's no x[n-1] available. For long signals this is negligible.
%
% =========================================================================
