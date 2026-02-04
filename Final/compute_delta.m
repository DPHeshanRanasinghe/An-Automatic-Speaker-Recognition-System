function delta = compute_delta(features, N)

if nargin < 2
    N = 2;  % Standard value: use 2 frames on each side
end

[num_frames, num_coeffs] = size(features);

if num_frames < 2 * N + 1
    warning('Too few frames (%d) for N=%d. Using N=%d instead.', ...
            num_frames, N, floor((num_frames-1)/2));
    N = floor((num_frames - 1) / 2);
end

if N < 1
    % If still not enough frames, return zeros
    delta = zeros(size(features));
    return;
end

% denominator = 2 * Σ(n=1 to N) n²
denominator = 2 * sum((1:N).^2);

% Pad features at boundaries
% To compute delta at frame t, we need frames from (t-N) to (t+N).
% For boundary frames (t < N or t > num_frames-N), we replicate
% the first/last frame.

% Pad with repeated first and last frames
padded = [repmat(features(1, :), N, 1); ...
          features; ...
          repmat(features(end, :), N, 1)];

% Now padded has size (num_frames + 2*N) × num_coeffs
% Original frame t is at index (t + N) in padded

% Compute delta for each frame
delta = zeros(num_frames, num_coeffs);

for t = 1:num_frames
    % In padded array, original frame t is at index (t + N)
    padded_idx = t + N;
    
    % Compute weighted difference
    numerator = zeros(1, num_coeffs);
    for n = 1:N
        numerator = numerator + n * (padded(padded_idx + n, :) - padded(padded_idx - n, :));
    end
    
    delta(t, :) = numerator / denominator;
end

% fprintf('Delta coefficients computed:\n');
% fprintf('  Input size:     %d frames × %d coeffs\n', num_frames, num_coeffs);
% fprintf('  N (window):     %d (uses %d frames total)\n', N, 2*N+1);
% fprintf('  Output size:    %d × %d\n', size(delta,1), size(delta,2));
% fprintf('  Delta range:    [%.4f, %.4f]\n', min(delta(:)), max(delta(:)));
% fprintf('  Delta mean:     %.6f\n', mean(delta(:)));
% fprintf('  Delta std:      %.4f\n', std(delta(:)));

end


% TECHNICAL NOTES:
% 1. Why delta features?
%    Static MFCC coefficients capture the spectral shape at each instant,
%    but speech is inherently dynamic. Delta features capture how the
%    spectrum CHANGES over time:
%    - Transitions between phonemes
%    - Formant movements
%    - Speaking rate variations
%    
%    Adding delta features typically improves speaker recognition by 5-15%.
%
% 2. Why delta-delta (acceleration)?
%    Delta-delta features capture the "acceleration" of spectral change.
%    They're the delta of delta, representing the second derivative.
%    This adds another layer of temporal dynamics.
%    
%    The standard feature set is:
%    - 13 MFCCs (static)
%    - 13 deltas (velocity)
%    - 13 delta-deltas (acceleration)
%    = 39 features total (very common in speech recognition)
%
% 3. Why N=2?
%    N=2 means we use frames (t-2, t-1, t, t+1, t+2) to compute delta[t].
%    - N=1: Very local, noisy
%    - N=2: Good balance (standard choice)
%    - N=3 or 4: Smoother but may blur rapid transitions
%
% 4. Boundary handling:
%    At the first/last few frames, we don't have enough neighbors.
%    Common solutions:
%    - Replicate first/last frame (used here)
%    - Zero-pad
%    - Mirror reflection
%    - Reduce N at boundaries
%    
%    Replication is most common and works well in practice.
%
% 5. Mathematical interpretation:
%    The delta formula is a weighted finite difference:
%    d[t] = Σ n*(c[t+n] - c[t-n]) / (2*Σn²)
%    
%    This is equivalent to a linear regression slope through points
%    (c[t-N], ..., c[t], ..., c[t+N]). The weights n give more
%    importance to frames farther from the center.
%
% 6. Alternative: Simple difference
%    Some implementations use: delta[t] = c[t+1] - c[t-1]
%    This is equivalent to N=1, unweighted. It's noisier but faster.
%
% 7. Computational cost:
%    Delta computation is O(num_frames * num_coeffs * N), which is
%    fast compared to the FFT and mel filterbank steps. Adding deltas
%    approximately doubles the feature dimension but adds <10% to
%    computation time.

