function plotSpectrogram(S, Fs, N)
    hopLength = floor(N/2);
    numFrames = size(S,2);
    timeAxis = (0:numFrames-1) * hopLength / Fs;
    freqAxis = (0:N/2-1) * Fs / N;

    figure
    imagesc(timeAxis, freqAxis, 20*log10(S + eps)) % log scale
    axis xy
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    title(['Spectrogram with Frame Length = ', num2str(N)])
    colorbar
end