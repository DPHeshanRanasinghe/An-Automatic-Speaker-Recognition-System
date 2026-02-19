# MFCC Feature Extraction from Scratch (MATLAB)

A complete signal processing implementation of **Mel-Frequency Cepstral Coefficients (MFCCs)** developed entirely from first principles in MATLAB.

This project manually implements every stage of the MFCC pipeline without using built-in MFCC functions. Each processing step is modularized to clearly demonstrate the underlying digital signal processing concepts.

The final output per frame is a **39-dimensional feature vector**:

- 13 Static MFCCs  
- 13 Delta coefficients  
- 13 Delta-Delta coefficients  

---

## Table of Contents

1. Project Overview  
2. System Architecture  
3. Repository Structure  
4. Development Procedure  
5. MFCC Processing Pipeline  
6. Mathematical Formulation  
7. Parameters  
8. Feature Export  
9. How to Run  
10. Dataset Details  
11. Dependencies  
12. References  

---

## Project Overview

The objective of this project is to construct the full MFCC extraction pipeline from scratch using MATLAB.

Given a raw `.wav` speech recording, the system performs:

1. Pre-emphasis filtering  
2. Frame segmentation  
3. Windowing  
4. FFT and power spectrum computation  
5. Mel filterbank processing  
6. Logarithmic compression  
7. Discrete Cosine Transform  
8. Delta and delta-delta feature computation  

This implementation is intended for academic use, research understanding, and DSP learning purposes.

---

## System Architecture
Audio (.wav)
|
v
Pre-emphasis
|
v
Frame Blocking
|
v
Hamming Window
|
v
FFT (512-point)
|
v
Power Spectrum
|
v
26-channel Mel Filterbank
|
v
Log Compression
|
v
DCT (retain 13 coefficients)
|
v
Delta + Delta-Delta
|
v
39-dimensional MFCC feature vectors

---


---

## Development Procedure

### Step 1 — Theoretical Study

Before coding, the following concepts were reviewed:

- Human auditory perception and mel scale  
- Short-time spectral analysis  
- Mel filterbank construction  
- Discrete Cosine Transform (DCT-II)  
- Temporal derivative features  

Supporting materials are included in:

- `MFCC/Learn_MFCC.ipynb`
- `MFCC/MFCC.ipynb`

---

### Step 2 — Modular MATLAB Implementation

Each stage of MFCC computation is implemented as a separate function.

| Step | Function | Description |
|------|----------|-------------|
| 1 | `preemphasis.m` | First-order high-pass filter |
| 2 | `frame_signal.m` | Segment signal into overlapping frames |
| 3 | `apply_window.m` | Apply Hamming window |
| 4 | `compute_power_spectrum.m` | 512-point FFT and power spectrum |
| 5 | `apply_mel_filterbank.m` | 26 triangular mel-spaced filters |
| 6 | `apply_log.m` | Logarithmic compression |
| 7 | `apply_dct.m` | DCT-II, keep first 13 coefficients |
| 8 | `compute_delta.m` | Compute delta and delta-delta |

---

## MFCC Processing Pipeline

### 1. Pre-emphasis

Enhances high-frequency components:

y[n] = x[n] − α x[n−1]


Default:
α = 0.97


---

### 2. Framing

Signal is divided into short-time frames:

- Frame length: 256 samples  
- Hop size: 100 samples  
- Overlap ≈ 60.9%

---

### 3. Windowing

Each frame is multiplied by a Hamming window:

w[n] = 0.54 − 0.46 cos(2πn/(N−1))


---

### 4. FFT and Power Spectrum

A 512-point FFT is applied:

P[k] = (1/N) |FFT(frame)|²


---

### 5. Mel Filterbank

Frequency conversion to mel scale:

mel(f) = 2595 log10(1 + f/700)


- 26 triangular filters  
- Evenly spaced in mel domain  

---

### 6. Log Compression

log_energy = log(mel_energy)


---

### 7. Discrete Cosine Transform

DCT-II applied to log mel energies:

c[n] = Σ log(E[k]) cos(n(k − 0.5)π/K)


First 13 coefficients retained.

---

### 8. Delta and Delta-Delta

First-order temporal derivative:

d[t] = ( Σ n(c[t+n] − c[t−n]) ) / (2 Σ n²)


Second derivative computed similarly.

---

## Final Output

Each frame produces:

13 MFCC
13 Delta
13 Delta-Delta
= 39-dimensional feature vector


---

## Parameters

| Parameter | Value |
|-----------|--------|
| Pre-emphasis α | 0.97 |
| Frame length | 256 samples |
| Hop size | 100 samples |
| FFT size | 512 |
| Number of mel filters | 26 |
| Retained MFCC coefficients | 13 |
| Output dimension | 39 |

---

## Feature Export

Run inside MATLAB:

```matlab
cd Final
export_mfcc_features
The script:

Scans .wav files

Finds the shortest recording

Truncates all signals to equal length

Extracts MFCC features

Saves .mat files

Stores metadata

Saved variables:

mfcc_coeffs

delta_mfcc

delta2_mfcc

features

Visualization Script

Final_assemble.mlx provides step-by-step visual verification:

Spectrogram

Mel filterbank shapes

MFCC heatmaps

Delta feature visualization

How to Run

Place audio files in:

Final/data/


In MATLAB:

cd Final
export_mfcc_features

Dataset Details
Property	Value
Sampling frequency	12500 Hz
Duration	~1–1.5 seconds
Frames per recording	~130–150
Dependencies
MATLAB

Signal Processing Toolbox (for audioread)

No built-in MFCC extraction functions are used.

References

S. Davis and P. Mermelstein (1980), "Comparison of Parametric Representations for Monosyllabic Word Recognition in Continuously Spoken Sentences"

L. Rabiner and R. Schafer, Digital Processing of Speech Signals

A. Oppenheim and R. Schafer, Discrete-Time Signal Processing


---

If you want, I can also generate:

- A more minimal one-page README  
- A more research-paper styled README  
- Or one formatted specifically for an IEEE project submission.


