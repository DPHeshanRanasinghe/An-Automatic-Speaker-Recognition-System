clear; clc;

[s, fs] = audioread('../data/raw/recordedSpeech.wav');
s_pre = preprocessSpeech(s);

N = length(s);
f = (0:N-1)*(fs/N);

S  = abs(fft(s));
Sp = abs(fft(s_pre));

figure;
plot(f(1:N/2), S(1:N/2), 'b');
hold on;
plot(f(1:N/2), Sp(1:N/2), 'r');
legend('Original','Pre-emphasized');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Effect of Pre-emphasis');
