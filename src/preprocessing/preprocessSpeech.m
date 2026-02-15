function s_pre = preprocessSpeech(s, alpha)
% preprocessSpeech
% Performs DC removal and pre-emphasis
%
% Inputs:
%   s     - raw speech signal (column vector)
%   alpha - pre-emphasis coefficient (default 0.97)
%
% Output:
%   s_pre - pre-processed speech signal

if nargin < 2
    alpha = 0.97;
end

% Ensure column vector
s = s(:);

% -----------------------------
% DC offset removal
% -----------------------------
s_dc = s - mean(s);

% -----------------------------
% Pre-emphasis filter
% -----------------------------
s_pre = filter([1 -alpha], 1, s_dc);

end
