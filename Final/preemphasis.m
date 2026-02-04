function emphasized = preemphasis(signal, alpha)
if nargin < 2
    alpha = 0.97;  % default value (standard in speech processing)
end

% Ensure signal is a column vector
if isrow(signal)
    signal = signal(:);
end

emphasized = filter([1 -alpha], 1, signal);

end

% TECHNICAL NOTES:
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

