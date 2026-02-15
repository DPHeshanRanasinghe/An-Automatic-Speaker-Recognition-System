clear; clc;

[s, fs] = audioread('../data/raw/recordedSpeech.wav');
s_pre = preprocessSpeech(s);

frames = frameSpeech(s_pre, fs, 25, 10);

figure;
subplot(3,1,1);
plot(frames(:,1));
title('Frame 1');

subplot(3,1,2);
plot(frames(:,2));
title('Frame 2');

subplot(3,1,3);
plot(frames(:,3));
title('Frame 3');
