function S = computeSpectrogram(x, Fs, N)
    % User-input N = frame length
    hopLength = floor(N/2);         % 50% overlap
    window    = hamming(N);         % Hamming window

    numFrames = floor((length(x)-N)/hopLength) + 1;
    S = zeros(N/2, numFrames);

    for i = 1:numFrames
        startIdx = (i-1)*hopLength + 1;
        frame = x(startIdx : startIdx+N-1);
        frame = frame .* window;

        X = myFFT(frame);             % FFT of frame
        S(:,i) = abs(X(1:N/2));     % take positive frequencies
    end
end