MFCC FROM SCRATCH - COMPLETE MATLAB IMPLEMENTATION
==================================================

This package contains a complete, from-scratch MFCC implementation in MATLAB
for your speaker recognition project.

PACKAGE CONTENTS
================
1. preemphasis.m          - Step 1: High-pass filter
2. frame_signal.m         - Step 2: Divide into frames
3. apply_window.m         - Step 3: Hamming windowing
4. compute_power_spectrum.m - Steps 4&5: FFT + Power
5. apply_mel_filterbank.m - Step 6: Mel filtering
6. apply_log.m            - Step 7: Logarithm
7. apply_dct.m            - Step 8: DCT
8. mfcc.m                 - MAIN function (calls all 7 helpers)
9. test_mfcc.m            - Test script with visualizations

QUICK START
===========
1. Copy all .m files to your project directory
2. Make sure you have melfb.m from your project
3. Run: test_mfcc.m
4. Check the visualizations to verify everything works

STEP-BY-STEP GUIDE
==================

FUNCTION 1: preemphasis.m
-------------------------
PURPOSE: Boost high frequencies (balance the spectrum)

MATH: y[n] = x[n] - 0.97 * x[n-1]

HOW TO USE:
    emphasized = preemphasis(signal, 0.97);

INPUTS:
    signal - audio waveform (any length)
    alpha  - coefficient (0.97 typical)

OUTPUT:
    emphasized - filtered signal (same length)

WHY IT MATTERS:
    Speech naturally has more low-frequency energy. This filter
    compensates by boosting highs.


FUNCTION 2: frame_signal.m
--------------------------
PURPOSE: Chop signal into short overlapping segments

MATH: frame_i starts at sample (i-1)*hop_size + 1

HOW TO USE:
    frames = frame_signal(signal, 256, 100);

INPUTS:
    signal       - input waveform
    frame_length - samples per frame (256 = 16ms at 16kHz)
    hop_size     - shift between frames (100 = 6ms at 16kHz)

OUTPUT:
    frames - matrix where each ROW is one frame
             Size: (num_frames × frame_length)

WHY IT MATTERS:
    Speech changes over time. We analyze short windows where
    it's approximately constant.


FUNCTION 3: apply_window.m
--------------------------
PURPOSE: Taper frame edges to reduce spectral leakage

MATH: windowed[n] = frame[n] * hamming[n]
      hamming[n] = 0.54 - 0.46*cos(2πn/(N-1))

HOW TO USE:
    windowed = apply_window(frames);

INPUT:
    frames - from frame_signal() (num_frames × frame_length)

OUTPUT:
    windowed_frames - same size, edges smoothly tapered

WHY IT MATTERS:
    Abrupt frame edges create false frequencies in the FFT.
    Windowing eliminates these artifacts.


FUNCTION 4: compute_power_spectrum.m
------------------------------------
PURPOSE: Convert to frequency domain and compute energy

MATH: X[k] = FFT(frame)
      P[k] = |X[k]|²

HOW TO USE:
    power = compute_power_spectrum(windowed_frames, 512);

INPUTS:
    windowed_frames - from apply_window()
    nfft           - FFT size (512 typical)

OUTPUT:
    power_spectrum - (num_frames × 257) for nfft=512
                     Only positive frequencies

WHY IT MATTERS:
    Frequency analysis reveals which frequencies have energy.


FUNCTION 5: apply_mel_filterbank.m
----------------------------------
PURPOSE: Convert linear frequency to perceptual mel scale

MATH: mel(f) = 2595 * log₁₀(1 + f/700)
      E[i] = Σ H[i,k] * P[k]  (weighted sum)

HOW TO USE:
    mel_energies = apply_mel_filterbank(power, 16000, 512, 26);

INPUTS:
    power_spectrum - from compute_power_spectrum()
    fs             - sampling rate (16000)
    nfft           - FFT size (512)
    num_filters    - mel filters (26 typical)

OUTPUT:
    mel_energies - (num_frames × 26)

**CRITICAL**: Check your melfb.m signature!
    This function calls: melfb(num_filters, nfft, fs)
    If yours is different, edit line 51 in apply_mel_filterbank.m

WHY IT MATTERS:
    Humans perceive pitch logarithmically. Mel scale matches this.


FUNCTION 6: apply_log.m
-----------------------
PURPOSE: Compress dynamic range, match human loudness perception

MATH: log_mel = log(mel_energies + ε)
      ε = eps ≈ 2.2e-16 (prevents log(0))

HOW TO USE:
    log_mel = apply_log(mel_energies);

INPUT:
    mel_energies - from apply_mel_filterbank()

OUTPUT:
    log_mel - same size

WHY IT MATTERS:
    Logarithm transforms multiplication into addition, compresses
    large ranges into manageable numbers.


FUNCTION 7: apply_dct.m
-----------------------
PURPOSE: Decorrelate features, compress to 13 coefficients

MATH: C[n] = DCT(log_mel energies)
      Keep first 13 coefficients

HOW TO USE:
    mfcc_coeffs = apply_dct(log_mel, 13);

INPUTS:
    log_mel    - from apply_log()
    num_coeffs - how many to keep (13 typical)

OUTPUT:
    mfcc_coeffs - (num_frames × 13) by default
                  Each ROW is one frame's MFCC vector

**ORIENTATION**: Check what train.m expects!
    If it wants (13 × num_frames), edit line 73 in apply_dct.m
    to NOT transpose.

WHY IT MATTERS:
    DCT concentrates energy into first few coefficients. We keep
    the ones with speaker information, discard noise.


FUNCTION 8: mfcc.m (MAIN)
-------------------------
PURPOSE: Orchestrate the entire pipeline

HOW TO USE:
    [audio, fs] = audioread('S1.wav');
    coeffs = mfcc(audio, fs);

INPUTS:
    signal - audio waveform
    fs     - sampling rate

OUTPUT:
    coeffs - MFCC matrix (num_frames × 13) or (13 × num_frames)

WHAT IT DOES:
    1. Calls preemphasis()
    2. Calls frame_signal()
    3. Calls apply_window()
    4. Calls compute_power_spectrum()
    5. Calls apply_mel_filterbank()
    6. Calls apply_log()
    7. Calls apply_dct()
    8. Returns final MFCC coefficients

PARAMETERS (edit in mfcc.m if needed):
    alpha        = 0.97    Pre-emphasis
    frame_length = 256     Frame size
    hop_size     = 100     Frame shift
    nfft         = 512     FFT size
    num_filters  = 26      Mel filters
    num_coeffs   = 13      MFCC coeffs


FUNCTION 9: test_mfcc.m
-----------------------
PURPOSE: Verify your implementation works

HOW TO USE:
    1. Edit line 28 to point to your audio file:
       audio_file = 'S1.wav';  % or 'TRAIN/S1.WAV'
    
    2. Run: test_mfcc
    
    3. Check:
       - No errors
       - No NaN or Inf values
       - MFCC range is roughly [-50, 50]
       - Visualizations look reasonable


INTEGRATION WITH YOUR PROJECT
==============================

Your project structure should be:

project/
├── TRAIN/
│   ├── S1.WAV
│   ├── S2.WAV
│   └── ...
├── TEST/
│   └── ...
├── mfcc.m              ← YOUR MAIN FUNCTION
├── preemphasis.m       ← Helper 1
├── frame_signal.m      ← Helper 2
├── apply_window.m      ← Helper 3
├── compute_power_spectrum.m ← Helper 4
├── apply_mel_filterbank.m   ← Helper 5
├── apply_log.m              ← Helper 6
├── apply_dct.m              ← Helper 7
├── melfb.m             ← PROVIDED (from project)
├── disteu.m            ← PROVIDED (from project)
├── vqlbg.m             ← YOU WILL WRITE THIS
├── train.m             ← PROVIDED (calls your mfcc.m)
└── test.m              ← PROVIDED (calls your mfcc.m)


HOW train.m USES YOUR mfcc.m
=============================

% In train.m (typical usage):
for speaker = 1:8
    % Load audio
    [speech, fs] = audioread(sprintf('TRAIN/S%d.WAV', speaker));
    
    % YOUR MFCC FUNCTION CALLED HERE
    features = mfcc(speech, fs);
    
    % Build codebook using VQ/LBG
    codebook = vqlbg(features, codebook_size);
    
    % Save
    save(sprintf('codebook_S%d.mat', speaker), 'codebook');
end


CRITICAL CHECKS BEFORE SUBMITTING
==================================

1. CHECK OUTPUT ORIENTATION
   --------------------------
   Open train.m and see how it uses the MFCC output.
   
   If it does: codebook = vqlbg(features, ...)
   and vqlbg expects (num_features × num_frames), then:
   → Go to mfcc.m line 128 and UNCOMMENT: coeffs = coeffs';
   
   If train.m transposes before vqlbg, or if vqlbg expects
   (num_frames × num_features), then:
   → Leave mfcc.m as is (rows = frames)

2. CHECK melfb.m SIGNATURE
   -----------------------
   Open your project's melfb.m and check the first line:
   
   function filterbank = melfb(???, ???, ???)
   
   Common signatures:
   A) melfb(num_filters, nfft, fs)     ← ASSUMED
   B) melfb(num_filters, fs, nfft)
   C) melfb(num_filters, nfft, fs, f_low, f_high)
   
   If yours is B or C:
   → Edit apply_mel_filterbank.m line 51

3. TEST ON ALL 8 SPEAKERS
   -----------------------
   for i = 1:8
       [audio, fs] = audioread(sprintf('TRAIN/S%d.WAV', i));
       coeffs = mfcc(audio, fs);
       fprintf('S%d: %d × %d\n', i, size(coeffs,1), size(coeffs,2));
   end
   
   Make sure all 8 work without errors.


TROUBLESHOOTING
===============

ERROR: "Matrix dimensions must agree"
→ Check melfb.m signature in apply_mel_filterbank.m
→ Check transpose in mfcc.m (line 128)

ERROR: "NaN values in output"
→ Check eps in apply_log.m (line 41)
→ Make sure audio file loaded correctly

ERROR: "Index exceeds matrix dimensions" in train.m
→ Check output orientation (see CHECK #1 above)

ERROR: "Undefined function 'melfb'"
→ Make sure melfb.m is in the same directory

SLOW PERFORMANCE:
→ Normal for MATLAB. 8 speakers should take < 5 seconds total.


UNDERSTANDING THE OUTPUT
=========================

WHAT IS THE OUTPUT?
    A matrix of MFCC coefficients.
    Default: (num_frames × 13)
    
    Each row is one frame (typically 10-30 ms of speech).
    Each column is one MFCC coefficient.

TYPICAL VALUES:
    - Coefficient 0: -20 to 20 (loudness)
    - Coefficient 1-12: -30 to 30 (spectral shape)
    - Mean near 0
    - Std around 5-15

WHAT DOES IT CAPTURE?
    - Vocal tract shape (formants)
    - Spectral envelope
    - Speaker-specific characteristics
    
WHAT DOES IT IGNORE?
    - Pitch (voice fundamental frequency)
    - Fine temporal details
    - Background noise (partially)


NEXT STEPS AFTER MFCC WORKS
============================

1. Implement vqlbg.m (Vector Quantization / LBG Algorithm)
2. Test train.m on all 8 speakers
3. Test test.m on unknown speakers
4. Evaluate recognition accuracy
5. If accuracy is low:
   - Try different num_filters (20-40)
   - Try different num_coeffs (10-15)
   - Add delta and delta-delta features
   - Implement cepstral mean normalization


REFERENCES
==========

The code implements the standard MFCC algorithm from:

[1] Davis & Mermelstein (1980), "Comparison of Parametric 
    Representations for Monosyllabic Word Recognition in 
    Continuously Spoken Sentences"

[2] Young et al., "The HTK Book" (Cambridge University)
    - Standard reference for speech recognition

[3] Ganchev et al. (2005), "Comparative evaluation of various
    MFCC implementations on the speaker verification task"


CONTACT & SUPPORT
=================

If you have questions:
1. Check the detailed comments in each .m file
2. Run test_mfcc.m and check the visualizations
3. Verify each function works independently
4. Check the troubleshooting section above


GOOD LUCK WITH YOUR PROJECT!
=============================
