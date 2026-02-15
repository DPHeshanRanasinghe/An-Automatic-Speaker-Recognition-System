clear; clc;

fs = 16000;
screen = 5;

sys = realTimeAudio(fs, screen);

disp('Speak into the microphone...');
pause(10);

stop(sys.clock);
stop(sys.recorder);

s = getaudiodata(sys.recorder);

audiowrite('../data/raw/recordedSpeech.wav', s, fs);
