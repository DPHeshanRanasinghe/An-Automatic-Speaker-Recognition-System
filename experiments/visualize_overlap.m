clear; clc;

[s, fs] = audioread('../data/raw/recordedSpeech.wav');
s_pre = preprocessSpeech(s);

figure;
plot(s_pre,'k');
hold on;

frameShift = round(10e-3 * fs);
frameLength = round(25e-3 * fs);

for i = 1:10
    startIdx = (i-1)*frameShift + 1;
    endIdx   = startIdx + frameLength - 1;
    plot(startIdx:endIdx, s_pre(startIdx:endIdx),'r');
end

title('Overlapping Frames on Speech Signal');
xlabel('Samples');
ylabel('Amplitude');
