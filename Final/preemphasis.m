function emphasized = preemphasis(signal, alpha)

if nargin < 2
    alpha = 0.97;
end

if isrow(signal)
    signal = signal(:);
end

emphasized = filter([1 -alpha], 1, signal);

end