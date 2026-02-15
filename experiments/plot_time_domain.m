clear; clc;

[s, fs] = audioread('../data/raw/recordedSpeech.wav');

s_pre = preprocessSpeech(s);

t = (0:length(s)-1)/fs;

figure;
subplot(2,1,1);
plot(t, s);
title('Original Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t, s_pre);
title('Pre-processed Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');
