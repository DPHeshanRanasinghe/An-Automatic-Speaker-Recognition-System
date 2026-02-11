# An Automatic Speaker Recognition System

A complete, end-to-end speaker recognition pipeline that identifies _who_ is speaking from a short audio recording. The system combines a **from-scratch MFCC feature extraction** implementation in MATLAB with a **GMM-UBM (Gaussian Mixture Model -- Universal Background Model)** speaker identification engine in Python, achieving **100% identification accuracy** on the included 8-speaker dataset.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Repository Structure](#repository-structure)
4. [Development Procedure](#development-procedure)
5. [Phase 1 -- MFCC Feature Extraction (MATLAB)](#phase-1----mfcc-feature-extraction-matlab)
6. [Phase 2 -- Feature Export](#phase-2----feature-export)
7. [Phase 3 -- GMM-UBM Speaker Recognition (Python)](#phase-3----gmm-ubm-speaker-recognition-python)
8. [Phase 4 -- Jupyter Notebook with Visualizations](#phase-4----jupyter-notebook-with-visualizations)
9. [How to Run](#how-to-run)
10. [Usage Guide -- Command-Line Scripts](#usage-guide----command-line-scripts)
11. [Technical Details](#technical-details)
12. [Results](#results)
13. [Dependencies](#dependencies)
14. [References](#references)

---

## Project Overview

The goal of this project is to build a system that, given a short speech segment from one of eight enrolled speakers, determines which speaker produced it and reports a confidence level for that prediction.

The project is divided into two major phases:

| Phase | Tool | Purpose |
|-------|------|---------|
| Feature Extraction | MATLAB | Implement every step of the MFCC algorithm from scratch -- pre-emphasis, framing, windowing, FFT, mel filterbank, log compression, DCT, and delta computation -- to produce 39-dimensional feature vectors. |
| Speaker Modelling | Python | Train a Universal Background Model on pooled data, MAP-adapt it to each speaker, score test utterances via log-likelihood ratios, and output speaker identity with calibrated confidence. |

---

## System Architecture

```
Audio (.wav)
    |
    v
[MATLAB -- MFCC from scratch]
    preemphasis  ->  frame_signal  ->  apply_window
        ->  compute_power_spectrum  ->  apply_mel_filterbank
        ->  apply_log  ->  apply_dct  ->  compute_delta
    |
    v
39-dim features per frame  (13 MFCC + 13 Delta + 13 Delta-Delta)
    |
    v
export_mfcc_features.m  -->  .mat files (exported_features/)
    |
    v
[Python -- GMM-UBM Engine]
    Load .mat  ->  Train UBM (pooled)  ->  MAP Adapt per speaker
        ->  Score (log-likelihood ratio)  ->  Softmax confidence
    |
    v
Predicted speaker + confidence %
```

At inference time, the Python pipeline can also extract MFCCs directly from a `.wav` file using `librosa`, eliminating the need for MATLAB.

---

## Repository Structure

```
An-Automatic-Speaker-Recognition-System/
|
|-- README.md                          <-- This file
|
|-- MFCC/                              <-- Learning materials and theory exploration
|   |-- matlab/                        <-- (Excluded from git - early prototypes)
|   |-- MFCC.ipynb                     <-- Python MFCC exploration notebook
|   |-- Learn_MFCC.ipynb               <-- Theory and derivation notebook
|   |-- ComputeMelfrequencyCepstralCoefficientsExample.mlx
|   |-- ExtractMFCCFromFrequencyDomainAudioExample.mlx
|   +-- Reference PDFs                 <-- Technical documentation
|
|-- Final/                             <-- Phase 2-4: Complete recognition system
|   |-- data/
|   |   |-- train/                     <-- 8 training recordings (s1.wav .. s8.wav)
|   |   +-- test/                      <-- 8 test recordings    (s1.wav .. s8.wav)
|   |
|   |-- exported_features/             <-- MATLAB-exported .mat files
|   |   |-- train/                     <-- s1_mfcc.mat .. s8_mfcc.mat
|   |   |-- test/                      <-- s1_mfcc.mat .. s8_mfcc.mat
|   |   +-- metadata.mat
|   |
|   |-- trained_models/
|   |   +-- gmm_ubm_model.pkl          <-- Serialized UBM + speaker GMMs + scaler
|   |
|   |-- MATLAB source files (from-scratch MFCC implementation)
|   |   |-- preemphasis.m              <-- Pre-emphasis filter (alpha=0.97)
|   |   |-- frame_signal.m             <-- Frame blocking (256 samples, hop 100)
|   |   |-- apply_window.m             <-- Hamming window
|   |   |-- compute_power_spectrum.m   <-- FFT + power spectrum (512-point)
|   |   |-- apply_mel_filterbank.m     <-- 26-channel mel filterbank
|   |   |-- apply_log.m                <-- Logarithmic compression
|   |   |-- apply_dct.m                <-- DCT for 13 MFCC coefficients
|   |   |-- compute_delta.m            <-- Delta and delta-delta computation
|   |   |-- mfcc.m                     <-- Wrapper: full pipeline
|   |   +-- melfb.m                    <-- Mel filterbank matrix generator
|   |
|   |-- export_mfcc_features.m         <-- Batch export: .wav -> .mat (MATLAB)
|   |-- Final_assemble.mlx             <-- MATLAB Live Script walkthrough
|   |
|   |-- train_gmm_ubm.py              <-- Train + evaluate GMM-UBM (Python)
|   |-- identify_speaker.py           <-- Real-time inference from wav/mat/mic
|   |-- test_pipeline.py              <-- End-to-end validation (librosa MFCCs)
|   +-- Speaker_Recognition_GMM_UBM.ipynb  <-- Full notebook with visualizations
```

---

## Development Procedure

The project was developed in the following sequence:

### Step 1 -- Study MFCC Theory

Researched the mathematics behind Mel-Frequency Cepstral Coefficients: the mel scale, filterbank design, the Discrete Cosine Transform, and the motivation for delta and delta-delta features. This groundwork is captured in the `MFCC/Learn_MFCC.ipynb` and `MFCC/MFCC.ipynb` notebooks, along with the reference PDFs.

### Step 2 -- Implement MFCC from Scratch in MATLAB

Built each processing stage as a standalone MATLAB function in the `Final/` directory:

| Step | Function | Operation |
|------|----------|-----------|
| 1 | `preemphasis.m` | First-order high-pass filter: `y[n] = x[n] - alpha * x[n-1]`, alpha = 0.97 |
| 2 | `frame_signal.m` | Divide the signal into overlapping frames (256 samples, hop 100) |
| 3 | `apply_window.m` | Apply a Hamming window to each frame |
| 4-5 | `compute_power_spectrum.m` | 512-point FFT followed by power spectrum computation |
| 6 | `apply_mel_filterbank.m` | Apply a 26-filter mel-spaced triangular filterbank |
| 7 | `apply_log.m` | Take the natural logarithm of mel energies |
| 8 | `apply_dct.m` | Discrete Cosine Transform, keeping the first 13 coefficients |
| 9 | `compute_delta.m` | Compute first-order (delta) and second-order (delta-delta) differences |

The output per frame is a 39-dimensional vector: 13 MFCCs + 13 deltas + 13 delta-deltas.

### Step 3 -- Validate the MATLAB Pipeline

Used the `Final/Final_assemble.mlx` Live Script to visually verify each intermediate result -- spectrograms, mel filterbank shapes, MFCC heatmaps, and delta patterns -- against known references.

**Note:** The `MFCC/matlab/` folder contains early prototypes and learning materials and is excluded from the repository. The production MATLAB implementation resides in `Final/`.

### Step 4 -- Record and Organize Speaker Data

Collected eight speakers (s1 through s8) with separate training and test recordings. All recordings are stored as `.wav` files under `Final/data/train/` and `Final/data/test/`.

### Step 5 -- Batch Export Features to .mat

Created `export_mfcc_features.m` to process every `.wav` file through the step-by-step MFCC pipeline (the same functions used in the Live Script, not the `mfcc()` wrapper). All audio is truncated to the shortest recording length to guarantee uniform frame counts. The exported `.mat` files contain `mfcc_coeffs`, `delta_mfcc`, `delta2_mfcc`, and `features`, all in MATLAB's native (coefficients x frames) orientation.

### Step 6 -- Choose a Speaker Modelling Approach

Evaluated three candidate architectures:

| Approach | Verdict |
|----------|---------|
| GMM-UBM with MAP adaptation | Selected. Well-suited for small-dataset closed-set identification; no deep-learning overhead. |
| Simple vector-space (cosine similarity on mean MFCC) | Too coarse; ignores temporal variation within an utterance. |
| Deep speaker embeddings (d-vector / x-vector) | Requires far more data than eight speakers provide. |

### Step 7 -- Build the Python GMM-UBM Pipeline

Implemented `train_gmm_ubm.py` with:

- A `Config` class centralizing all hyperparameters.
- A data loader that transposes MATLAB's (39 x N) matrices to Python's (N x 39) convention and horizontally stacks the three coefficient sets into (N x 39).
- A `GMMUBMSystem` class encapsulating UBM training (sklearn `GaussianMixture`), MAP adaptation (mean and weight update with configurable relevance factor), scoring (log-likelihood ratio against the UBM), and identification (softmax over scores).
- Model serialization to `trained_models/gmm_ubm_model.pkl`.

### Step 8 -- Build the Inference Script

Created `identify_speaker.py`, which loads the saved model and accepts three input modes:

- `--audio <file.wav>`: extract MFCCs via librosa and identify.
- `--mat <file.mat>`: load pre-extracted MATLAB features and identify.
- `--record --duration N`: record N seconds from the microphone, extract MFCCs, and identify.

### Step 9 -- Build the Validation Test

Created `test_pipeline.py`, which runs the full train-evaluate cycle from raw `.wav` files using librosa-based MFCC extraction. This serves as a self-contained sanity check that does not depend on MATLAB at all.

### Step 10 -- Debug Data-Orientation Mismatch

When the MATLAB-exported `.mat` files were first loaded in Python, the system produced incorrect results because MATLAB stores matrices as (coefficients x frames) while the Python code expected (frames x features). The loader was corrected to transpose each of the three coefficient matrices individually and then concatenate horizontally.

### Step 11 -- Create the Jupyter Notebook with Visualizations

Converted the training pipeline into `Speaker_Recognition_GMM_UBM.ipynb`, a 19-section notebook containing:

- Data loading and summary tables
- Frames-per-speaker bar charts
- MFCC feature heatmaps for sample speakers
- KDE plots of selected coefficients per speaker
- PCA scatter plots of the 39-dim feature space
- UBM component visualization in PCA space
- MAP adaptation magnitude heatmaps
- Adaptation coefficient (alpha) bar charts
- Score matrix heatmap (log-likelihood ratios)
- Confusion matrices (counts and percentages)
- Confidence heatmap (softmax probabilities)
- Genuine vs. impostor score distributions with EER computation
- ROC curve with AUC
- Single-utterance identification demo (from `.mat`)
- Audio-based identification demo (from `.wav` via librosa)
- Model save/load verification
- Hyperparameter grid search over UBM components and MAP relevance factor

---

## Phase 1 -- MFCC Feature Extraction (MATLAB)

All production MATLAB code resides in the `Final/` directory.

### Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `alpha` | 0.97 | Pre-emphasis coefficient |
| `frame_length` | 256 | Samples per frame |
| `hop_size` | 100 | Samples between frame starts (60.9% overlap) |
| `nfft` | 512 | FFT size |
| `num_filters` | 26 | Number of mel filterbank channels |
| `num_coeffs` | 13 | Number of MFCC coefficients retained |
| Output dimension | 39 | 13 MFCC + 13 delta + 13 delta-delta |

### Pipeline Equation Summary

Pre-emphasis:

```
y[n] = x[n] - 0.97 * x[n-1]
```

Mel scale conversion:

```
mel(f) = 2595 * log10(1 + f / 700)
```

Power spectrum:

```
P[k] = (1 / N) * |FFT(frame)|^2
```

MFCC (via DCT-II):

```
c[n] = sum_k( log(mel_energy[k]) * cos(n * (k - 0.5) * pi / K) )
```

Delta (first-order finite difference):

```
d[t] = ( sum_{n=1}^{N} n * (c[t+n] - c[t-n]) ) / ( 2 * sum_{n=1}^{N} n^2 )
```

---

## Phase 2 -- Feature Export

Run in MATLAB from the `Final/` directory:

```matlab
>> export_mfcc_features
```

This script:

1. Scans all `.wav` files in `data/train/` and `data/test/` to find the shortest recording.
2. Truncates every recording to that length so all speakers produce the same number of frames.
3. Processes each file through the full step-by-step MFCC pipeline (the same individual function calls used in the Live Script).
4. Saves per-speaker `.mat` files into `exported_features/train/` and `exported_features/test/`.
5. Writes a `metadata.mat` file recording all parameters.

---

## Phase 3 -- GMM-UBM Speaker Recognition (Python)

### Why GMM-UBM

The Gaussian Mixture Model -- Universal Background Model is the standard generative approach for speaker recognition when training data is limited. Instead of training an independent GMM for each speaker (which would overfit on approximately 130 frames), the system:

1. Trains a single UBM on all pooled training data, capturing the general structure of speech.
2. Adapts the UBM to each speaker using Maximum A Posteriori (MAP) estimation, which shifts only the relevant means and weights while inheriting robust covariance estimates from the UBM.

### MAP Adaptation

For each Gaussian component _k_ in the UBM:

```
alpha_k = n_k / (n_k + r)
adapted_mean_k = alpha_k * speaker_mean_k + (1 - alpha_k) * ubm_mean_k
```

where `n_k` is the soft count of frames assigned to component _k_, and `r` is the relevance factor (default 16). A higher relevance factor keeps the adapted model closer to the UBM; a lower value gives more weight to the speaker's data.

### Scoring

For a test utterance _X_:

```
score(X, speaker) = log P(X | speaker_GMM) - log P(X | UBM)
```

The predicted speaker is the one with the highest score. Confidence is computed by applying softmax across all speaker scores.

---

## Phase 4 -- Jupyter Notebook with Visualizations

`Final/Speaker_Recognition_GMM_UBM.ipynb` reproduces the entire training and evaluation pipeline in an interactive notebook with 19 sections of code and commentary, plus comprehensive plots covering data exploration, model internals, and performance metrics. The final section performs a grid search over UBM component counts (8, 16, 32, 64) and MAP relevance factors (4, 8, 16, 32).

---

## How to Run

### Prerequisites

- MATLAB R2020a or later (for MFCC extraction and export)
- Python 3.10+ with the packages listed in [Dependencies](#dependencies)
- Audio recordings placed in `Final/data/train/` and `Final/data/test/`

### Full Pipeline (MATLAB + Python)

```bash
# 1. In MATLAB, navigate to Final/ and run:
>> export_mfcc_features

# 2. In a terminal, navigate to Final/ and run:
cd Final
python train_gmm_ubm.py
```

### Python-Only Pipeline (no MATLAB required)

```bash
cd Final
python test_pipeline.py
```

This extracts MFCCs from `.wav` files directly using `librosa`, trains the GMM-UBM, evaluates on the test set, and saves the trained model.

### Interactive Notebook

Open `Final/Speaker_Recognition_GMM_UBM.ipynb` in VS Code or Jupyter and run all cells. The notebook loads the MATLAB-exported `.mat` files, trains the system, and produces all visualizations.

---

## Usage Guide -- Command-Line Scripts

### train_gmm_ubm.py

Train the GMM-UBM system from MATLAB-exported `.mat` features and evaluate on the test set.

```bash
cd Final

# Train with default settings (16 components, relevance 16):
python train_gmm_ubm.py

# Train with custom hyperparameters:
python train_gmm_ubm.py --components 32 --relevance 8

# Evaluate only (load previously saved model):
python train_gmm_ubm.py --evaluate
```

Output: per-speaker predictions with confidence, overall accuracy, and a score matrix. The trained model is saved to `trained_models/gmm_ubm_model.pkl`.

### identify_speaker.py

Identify who is speaking in a new recording. Requires a trained model (run `train_gmm_ubm.py` or `test_pipeline.py` first).

```bash
cd Final

# Identify from a .wav file:
python identify_speaker.py --audio data/test/s3.wav

# Identify from a MATLAB .mat feature file:
python identify_speaker.py --mat exported_features/test/s3_mfcc.mat

# Record from the microphone for 3 seconds and identify:
python identify_speaker.py --record --duration 3

# Record for 5 seconds using a specific sampling rate:
python identify_speaker.py --record --duration 5 --sr 12500
```

Output: predicted speaker, confidence percentage, and a ranked list of all speakers with their scores.

### test_pipeline.py

Run the full pipeline from raw `.wav` files without any MATLAB involvement. This is useful for quick validation.

```bash
cd Final
python test_pipeline.py
```

The script loads `.wav` files from `data/train/` and `data/test/`, extracts 39-dim MFCC features using `librosa`, trains the UBM, adapts per speaker, evaluates, and prints results. It also saves the trained model so that `identify_speaker.py` can use it.

**Important:** All three scripts must be run from the `Final/` directory so that relative paths to `data/`, `exported_features/`, and `trained_models/` resolve correctly.

---

## Technical Details

### Hyperparameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `UBM_N_COMPONENTS` | 16 | Number of Gaussian components in the UBM |
| `COVARIANCE_TYPE` | `diag` | Diagonal covariance (standard for speaker recognition) |
| `MAP_RELEVANCE_FACTOR` | 16.0 | Controls adaptation strength |
| `MAP_ADAPT_MEANS` | True | Adapt Gaussian means |
| `MAP_ADAPT_WEIGHTS` | True | Adapt mixture weights |
| `MAP_ADAPT_COVARS` | False | Do not adapt covariances (insufficient data) |
| `USE_FEATURE_SCALING` | True | Zero-mean, unit-variance normalization |

### Data

| Property | Value |
|----------|-------|
| Number of speakers | 8 (s1 through s8) |
| Recordings per speaker | 1 training + 1 test |
| Sampling frequency | 12500 Hz |
| Approximate duration | 1 -- 1.5 seconds per recording |
| Frames per speaker | Approximately 130 (train) and 150 (test) |

### MATLAB-to-Python Data Handling

MATLAB saves matrices in column-major order. The MFCC export produces:

- `mfcc_coeffs`: shape (13 x num_frames)
- `delta_mfcc`: shape (13 x num_frames)
- `delta2_mfcc`: shape (13 x num_frames)

The Python loader transposes each matrix to (num_frames x 13) and horizontally stacks them into a single (num_frames x 39) array.

---

## Results

### Identification Accuracy

| Evaluation Method | Accuracy |
|-------------------|----------|
| MATLAB-exported features (train_gmm_ubm.py) | 100% (8/8) |
| Librosa-extracted features (test_pipeline.py) | 100% (8/8) |

### Hyperparameter Grid Search

Tested all combinations of UBM components in {8, 16, 32, 64} and MAP relevance factor in {4, 8, 16, 32}. Nearly all configurations achieved 100% accuracy, with only the (16 components, relevance 4) and (16 components, relevance 8) settings dropping to 87.5%. This indicates the system is robust across a wide range of hyperparameters for this dataset.

### Equal Error Rate

The EER and AUC are computed in the Jupyter notebook from genuine (diagonal) and impostor (off-diagonal) score distributions, with ROC curves plotted for visual assessment.

---

## Dependencies

### MATLAB

- Signal Processing Toolbox (for `audioread`)

### Python

| Package | Purpose |
|---------|---------|
| `numpy` | Numerical operations |
| `scipy` | Loading `.mat` files |
| `scikit-learn` | `GaussianMixture`, `StandardScaler`, `PCA`, metrics |
| `matplotlib` | Plotting |
| `seaborn` | Statistical visualizations |
| `librosa` | Python-based MFCC extraction and audio loading |
| `sounddevice` | Microphone recording (optional, for `--record` mode) |

Install all Python dependencies:

```bash
pip install numpy scipy scikit-learn matplotlib seaborn librosa sounddevice
```

---

## References

- D. A. Reynolds, T. F. Quatieri, and R. B. Dunn, "Speaker Verification Using Adapted Gaussian Mixture Models," _Digital Signal Processing_, vol. 10, no. 1-3, pp. 19--41, 2000.
- S. B. Davis and P. Mermelstein, "Comparison of Parametric Representations for Monosyllabic Word Recognition in Continuously Spoken Sentences," _IEEE Transactions on Acoustics, Speech, and Signal Processing_, vol. 28, no. 4, pp. 357--366, 1980.
- J.-L. Gauvain and C.-H. Lee, "Maximum a Posteriori Estimation for Multivariate Gaussian Mixture Observations of Markov Chains," _IEEE Transactions on Speech and Audio Processing_, vol. 2, no. 2, pp. 291--298, 1994.