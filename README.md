# An Automatic Speaker Recognition System

This project is a complete speaker recognition system that identifies **who is speaking** from a short audio recording.

The system has two main parts. First, the MFCC feature extraction pipeline is implemented from scratch in MATLAB. Then, the extracted features are used in Python to train a GMM-UBM based speaker identification system.

The purpose of this project is not only to build a working system, but also to understand the full signal-processing and machine-learning pipeline behind speaker recognition.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Repository Structure](#repository-structure)
4. [Development Procedure](#development-procedure)
5. [Phase 1 -- MFCC Feature Extraction in MATLAB](#phase-1----mfcc-feature-extraction-in-matlab)
6. [Phase 2 -- Feature Export](#phase-2----feature-export)
7. [Phase 3 -- GMM-UBM Speaker Recognition in Python](#phase-3----gmm-ubm-speaker-recognition-in-python)
8. [Phase 4 -- Jupyter Notebook with Visualizations](#phase-4----jupyter-notebook-with-visualizations)
9. [How to Run](#how-to-run)
10. [Usage Guide](#usage-guide)
11. [Technical Details](#technical-details)
12. [Results](#results)
13. [Dependencies](#dependencies)
14. [Important Notes](#important-notes)
15. [References](#references)

---

## Project Overview

The goal of this project is to identify the speaker from a short speech recording. The current dataset contains 8 enrolled speakers, labelled from `s1` to `s8`.

For each audio recording, the system extracts MFCC-based features. These features are then used to train a speaker recognition model. During testing, the model compares the test utterance against all enrolled speaker models and predicts the most likely speaker.

The complete feature vector for each frame has 39 values:

```text
13 MFCC coefficients
+ 13 Delta coefficients
+ 13 Delta-Delta coefficients
= 39 features per frame
```

In MATLAB, the exported feature matrix is stored as:

```text
39 × M
```

where:

```text
39 = feature dimension
M  = number of frames
```

When loaded into Python, this is converted to:

```text
M × 39
```

because Python machine learning libraries usually expect:

```text
samples × features
```

---

## System Architecture

```text
Audio (.wav)
    |
    v
[MATLAB -- MFCC from scratch]
    |
    |-- preemphasis.m
    |-- frame_signal.m
    |-- apply_window.m
    |-- compute_power_spectrum.m
    |-- melfb.m
    |-- apply_mel_filterbank.m
    |-- apply_log.m
    |-- apply_dct.m
    |-- compute_delta.m
    |
    v
39-dimensional features per frame
    |
    v
export_mfcc_features.m
    |
    v
MATLAB .mat feature files
    |
    v
[Python -- GMM-UBM Speaker Recognition]
    |
    |-- Load .mat files
    |-- Convert MATLAB feature orientation to Python format
    |-- Train Universal Background Model
    |-- MAP adapt one model per speaker
    |-- Score test utterances
    |
    v
Predicted speaker + confidence score
```

The Python side also includes a `librosa`-based pipeline, so speaker recognition can be tested directly from `.wav` files without depending on MATLAB-exported features.

---

## Repository Structure

```text
An-Automatic-Speaker-Recognition-System/
|
|-- README.md                          <-- This file
|
|-- MFCC/                              <-- Learning materials and theory exploration
|   |-- matlab/                        <-- Early prototypes and experiments
|   |-- MFCC.ipynb                     <-- Python MFCC exploration notebook
|   |-- Learn_MFCC.ipynb               <-- MFCC theory and derivation notebook
|   |-- ComputeMelfrequencyCepstralCoefficientsExample.mlx
|   |-- ExtractMFCCFromFrequencyDomainAudioExample.mlx
|   +-- Reference PDFs                 <-- Technical documentation
|
|-- Final/                             <-- Final speaker recognition system
|   |-- data/
|   |   |-- train/                     <-- Training recordings: s1.wav to s8.wav
|   |   +-- test/                      <-- Test recordings: s1.wav to s8.wav
|   |
|   |-- exported_features/             <-- MATLAB-exported feature files
|   |   |-- train/                     <-- s1_mfcc.mat to s8_mfcc.mat
|   |   |-- test/                      <-- s1_mfcc.mat to s8_mfcc.mat
|   |   +-- metadata.mat
|   |
|   |-- trained_models/
|   |   +-- gmm_ubm_model.pkl          <-- Saved UBM, speaker GMMs, and scaler
|   |
|   |-- MATLAB source files
|   |   |-- preemphasis.m              <-- Pre-emphasis filter
|   |   |-- frame_signal.m             <-- Frame blocking
|   |   |-- apply_window.m             <-- Hamming window
|   |   |-- compute_power_spectrum.m   <-- FFT and power spectrum
|   |   |-- melfb.m                    <-- Mel filterbank generator
|   |   |-- apply_mel_filterbank.m     <-- Mel filterbank application
|   |   |-- apply_log.m                <-- Log compression
|   |   |-- apply_dct.m                <-- DCT for MFCC coefficients
|   |   |-- compute_delta.m            <-- Delta and delta-delta calculation
|   |   +-- mfcc.m                     <-- Full MATLAB MFCC wrapper
|   |
|   |-- export_mfcc_features.m         <-- Batch feature export script
|   |-- Final_assemble.mlx             <-- MATLAB Live Script walkthrough
|   |
|   |-- train_gmm_ubm.py               <-- Train and evaluate GMM-UBM system
|   |-- identify_speaker.py            <-- Speaker identification script
|   |-- test_pipeline.py               <-- Python-only validation pipeline
|   +-- Speaker_Recognition_GMM_UBM.ipynb
```

---

## Development Procedure

The project was developed step by step, starting from MFCC theory and ending with the final speaker recognition system.

### Step 1 -- Study MFCC Theory

First, the mathematical background of MFCC was studied. This included:

- speech signal preprocessing,
- pre-emphasis,
- frame blocking,
- windowing,
- FFT and power spectrum,
- mel scale conversion,
- triangular mel filterbanks,
- logarithmic compression,
- DCT,
- delta and delta-delta features.

The theory exploration is included in the `MFCC/` folder through notebooks and reference documents.

---

### Step 2 -- Implement MFCC from Scratch in MATLAB

Each part of the MFCC pipeline was implemented as a separate MATLAB function.

| Step | MATLAB File | Purpose |
|------|-------------|---------|
| 1 | `preemphasis.m` | Applies the high-pass pre-emphasis filter |
| 2 | `frame_signal.m` | Splits the audio signal into overlapping frames |
| 3 | `apply_window.m` | Applies a Hamming window to each frame |
| 4 | `compute_power_spectrum.m` | Computes FFT and power spectrum |
| 5 | `melfb.m` | Creates the mel filterbank matrix |
| 6 | `apply_mel_filterbank.m` | Applies the mel filters to the power spectrum |
| 7 | `apply_log.m` | Applies logarithmic compression |
| 8 | `apply_dct.m` | Applies DCT and keeps 13 MFCC coefficients |
| 9 | `compute_delta.m` | Computes delta and delta-delta features |

The final output of the MATLAB pipeline is:

```text
features = 39 × M
```

where each column corresponds to one frame.

---

### Step 3 -- Validate the MATLAB Pipeline

The file `Final_assemble.mlx` was created to visualize the full MATLAB MFCC process.

It includes plots for:

- raw audio waveform,
- pre-emphasized waveform,
- original and windowed frames,
- power spectrum,
- mel filterbank,
- mel energies,
- log-mel energies,
- MFCC heatmap,
- delta MFCC heatmap,
- delta-delta MFCC heatmap,
- final 39-dimensional feature matrix.

This helped verify that every stage of the MFCC pipeline was working correctly.

---

### Step 4 -- Organize Speaker Data

The dataset contains 8 speakers:

```text
s1, s2, s3, s4, s5, s6, s7, s8
```

Each speaker has:

```text
1 training recording
1 test recording
```

The files are organized as:

```text
Final/data/train/
Final/data/test/
```

---

### Step 5 -- Export Features to .mat Files

The MATLAB script `export_mfcc_features.m` processes all `.wav` files in the train and test folders.

It performs the following operations:

1. Reads all training and test `.wav` files.
2. Finds the shortest recording.
3. Truncates all recordings to the same length.
4. Extracts MFCC, delta, and delta-delta features.
5. Saves the features as `.mat` files.
6. Saves metadata such as feature dimension, sampling frequency, and MFCC parameters.

Each exported `.mat` file contains:

```text
mfcc_coeffs   = 13 × M
delta_mfcc    = 13 × M
delta2_mfcc   = 13 × M
features      = 39 × M
speaker_id
fs
```

---

### Step 6 -- Choose the Speaker Recognition Model

Three modelling approaches were considered.

| Approach | Decision |
|----------|----------|
| Mean MFCC with cosine similarity | Too simple and loses frame-level variation |
| Deep speaker embeddings | Not suitable for this small dataset |
| GMM-UBM with MAP adaptation | Selected |

GMM-UBM was selected because it works well with small speaker datasets and MFCC features. It is also a classical and interpretable approach for speaker recognition.

---

### Step 7 -- Build the Python GMM-UBM Pipeline

The Python training script `train_gmm_ubm.py` was developed to:

- load MATLAB-exported `.mat` features,
- convert the feature shape from `39 × M` to `M × 39`,
- scale the features,
- train a Universal Background Model,
- adapt one GMM model for each speaker,
- evaluate the test speakers,
- save the trained model.

The trained model is saved as:

```text
Final/trained_models/gmm_ubm_model.pkl
```

---

### Step 8 -- Build the Speaker Identification Script

The script `identify_speaker.py` was created for inference.

It supports three input modes:

```text
1. Identify from a .wav file
2. Identify from a MATLAB .mat feature file
3. Record from microphone and identify
```

This makes the system usable both for testing and for simple real-time demonstrations.

---

### Step 9 -- Build the Python-Only Test Pipeline

The file `test_pipeline.py` runs a complete Python-only version of the system.

It:

- loads raw `.wav` files,
- extracts MFCC features using `librosa`,
- trains the GMM-UBM model,
- evaluates speaker recognition accuracy,
- saves the model.

This is useful because it verifies the speaker recognition part without depending on MATLAB.

---

### Step 10 -- Fix MATLAB-to-Python Orientation

One important issue was the difference between MATLAB and Python feature orientation.

MATLAB exports features as:

```text
39 × M
```

where columns are frames.

Python expects:

```text
M × 39
```

where rows are samples and columns are feature dimensions.

Therefore, the Python loader transposes the MATLAB matrices before training.

---

### Step 11 -- Create the Jupyter Notebook

The notebook `Speaker_Recognition_GMM_UBM.ipynb` was created to explain and visualize the full speaker recognition system.

It includes:

- data loading summary,
- feature shape verification,
- MFCC heatmaps,
- delta and delta-delta visualizations,
- PCA plots,
- UBM component visualization,
- MAP adaptation analysis,
- score matrix,
- confusion matrix,
- confidence heatmap,
- ROC curve,
- EER calculation,
- single utterance identification demo,
- audio-based identification demo,
- model save/load verification,
- hyperparameter grid search.

---

## Phase 1 -- MFCC Feature Extraction in MATLAB

All final MATLAB files are stored in the `Final/` directory.

### MFCC Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `alpha` | 0.97 | Pre-emphasis coefficient |
| `frame_length` | 256 | Number of samples per frame |
| `hop_size` | 100 | Number of samples between adjacent frames |
| `nfft` | 512 | FFT size |
| `num_filters` | 26 | Number of mel filters |
| `num_coeffs` | 13 | Number of MFCC coefficients |
| `delta_N` | 2 | Delta calculation window |
| Output dimension | 39 | 13 MFCC + 13 delta + 13 delta-delta |

### Main Equations

Pre-emphasis:

```text
y[n] = x[n] - 0.97x[n-1]
```

Frame blocking:

```text
x_m[n] = x[n + mS]
```

Power spectrum:

```text
P[k] = |X[k]|^2 / N
```

Mel scale:

```text
mel(f) = 2595 log10(1 + f / 700)
```

Log-mel energy:

```text
E_log = log(E + epsilon)
```

DCT:

```text
c[n] = sum_k E_log[k] cos(pi n (2k + 1) / 2K)
```

Delta:

```text
delta[t] = sum_n n(c[t+n] - c[t-n]) / (2 sum_n n^2)
```

---

## Phase 2 -- Feature Export

Run the following command in MATLAB from the `Final/` directory:

```matlab
export_mfcc_features
```

This creates:

```text
Final/exported_features/
|-- train/
|   |-- s1_mfcc.mat
|   |-- s2_mfcc.mat
|   +-- ...
|
|-- test/
|   |-- s1_mfcc.mat
|   |-- s2_mfcc.mat
|   +-- ...
|
+-- metadata.mat
```

The exported features are stored in MATLAB orientation:

```text
features = 39 × M
```

This orientation is kept intentionally during MATLAB processing and converted only after loading into Python.

---

## Phase 3 -- GMM-UBM Speaker Recognition in Python

### Why GMM-UBM?

GMM-UBM is a suitable method for this project because the dataset is small.

Instead of training a completely independent model for each speaker, the system first trains a general speech model called the Universal Background Model. Then this model is adapted to each speaker.

This helps reduce overfitting and gives better speaker models when limited data is available.

---

### Universal Background Model

The UBM is trained using all training speakers together.

If the training feature vectors are:

```text
X = {x1, x2, ..., xT}
```

the UBM models the general distribution of speech features using a Gaussian Mixture Model:

```text
P(x | UBM) = sum_k w_k N(x | mu_k, Sigma_k)
```

where:

```text
w_k      = mixture weight
mu_k     = Gaussian mean
Sigma_k  = covariance matrix
```

---

### MAP Adaptation

Each speaker model is created by adapting the UBM using that speaker's training features.

For Gaussian component `k`:

```text
alpha_k = n_k / (n_k + r)
```

where:

```text
n_k = soft count of frames assigned to component k
r   = relevance factor
```

The adapted mean is:

```text
adapted_mean_k = alpha_k * speaker_mean_k + (1 - alpha_k) * ubm_mean_k
```

A larger relevance factor keeps the adapted model closer to the UBM.  
A smaller relevance factor allows stronger adaptation to the speaker data.

---

### Scoring

For a test utterance `X`, the score for each speaker is calculated as:

```text
score(X, speaker) = log P(X | speaker_GMM) - log P(X | UBM)
```

The speaker with the highest score is selected:

```text
predicted speaker = argmax(score)
```

Confidence is calculated using softmax over the speaker scores.

---

## Phase 4 -- Jupyter Notebook with Visualizations

The notebook:

```text
Final/Speaker_Recognition_GMM_UBM.ipynb
```

contains the full speaker recognition pipeline with visual explanations.

It includes:

- dataset summary,
- MFCC feature visualization,
- feature distribution plots,
- PCA projection,
- UBM visualization,
- MAP adaptation visualization,
- score matrix,
- confusion matrix,
- ROC curve,
- EER calculation,
- hyperparameter search.

---

## How to Run

### Prerequisites

Install MATLAB and Python before running the full system.

Recommended setup:

```text
MATLAB R2020a or later
Python 3.10 or later
```

The audio files should be placed in:

```text
Final/data/train/
Final/data/test/
```

---

### Full Pipeline: MATLAB + Python

Step 1: Run MATLAB feature export.

```matlab
cd Final
export_mfcc_features
```

Step 2: Train and evaluate the Python GMM-UBM system.

```bash
cd Final
python train_gmm_ubm.py
```

---

### Python-Only Pipeline

This version does not use MATLAB-exported `.mat` files. It extracts MFCC features directly from `.wav` files using `librosa`.

```bash
cd Final
python test_pipeline.py
```

---

### Interactive Notebook

Open the notebook:

```text
Final/Speaker_Recognition_GMM_UBM.ipynb
```

Then run all cells.

---

## Usage Guide

### train_gmm_ubm.py

Train and evaluate the GMM-UBM model using MATLAB-exported features.

```bash
cd Final
python train_gmm_ubm.py
```

Train with custom hyperparameters:

```bash
python train_gmm_ubm.py --components 32 --relevance 8
```

Evaluate using a previously saved model:

```bash
python train_gmm_ubm.py --evaluate
```

The trained model is saved to:

```text
Final/trained_models/gmm_ubm_model.pkl
```

---

### identify_speaker.py

Identify a speaker from a new input.

Identify from a `.wav` file:

```bash
cd Final
python identify_speaker.py --audio data/test/s3.wav
```

Identify from a MATLAB `.mat` feature file:

```bash
python identify_speaker.py --mat exported_features/test/s3_mfcc.mat
```

Record from microphone and identify:

```bash
python identify_speaker.py --record --duration 3
```

Record with a specific sampling rate:

```bash
python identify_speaker.py --record --duration 5 --sr 12500
```

The output includes:

- predicted speaker,
- confidence percentage,
- ranked speaker scores.

---

### test_pipeline.py

Run the full Python-only pipeline from raw `.wav` files:

```bash
cd Final
python test_pipeline.py
```

This script:

- loads training and test `.wav` files,
- extracts MFCC features using `librosa`,
- trains the GMM-UBM system,
- evaluates the system,
- saves the trained model.

---

## Technical Details

### Python Hyperparameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `UBM_N_COMPONENTS` | 16 | Number of Gaussian components in the UBM |
| `COVARIANCE_TYPE` | `diag` | Diagonal covariance matrix |
| `MAP_RELEVANCE_FACTOR` | 16.0 | Controls MAP adaptation strength |
| `MAP_ADAPT_MEANS` | True | Adapt Gaussian means |
| `MAP_ADAPT_WEIGHTS` | True | Adapt mixture weights |
| `MAP_ADAPT_COVARS` | False | Keep UBM covariances fixed |
| `USE_FEATURE_SCALING` | True | Apply zero-mean, unit-variance scaling |

---

### Data Summary

| Property | Value |
|----------|-------|
| Number of speakers | 8 |
| Speaker labels | `s1` to `s8` |
| Training recordings | 1 per speaker |
| Test recordings | 1 per speaker |
| Sampling frequency | 12500 Hz |
| Approximate duration | 1 to 1.5 seconds |
| MATLAB feature shape | `39 × M` |
| Python feature shape | `M × 39` |

---

### MATLAB-to-Python Data Handling

MATLAB saves the extracted features as:

```text
mfcc_coeffs   = 13 × M
delta_mfcc    = 13 × M
delta2_mfcc   = 13 × M
features      = 39 × M
```

Python loads the `.mat` files and converts them to:

```text
features = M × 39
```

This is necessary because scikit-learn expects each row to be one sample or frame.

---

## Results

### Identification Accuracy

On the current 8-speaker dataset, the system achieved:

| Evaluation Method | Accuracy |
|-------------------|----------|
| MATLAB-exported features | 100% |
| Python `librosa` features | 100% |

This confirms that the complete pipeline works correctly on the current dataset.

However, the dataset is small, so this result should be understood as a successful project-level validation rather than a production-level benchmark. For a stronger evaluation, the dataset should include more speakers, more recordings per speaker, different microphones, background noise, and different recording conditions.

---

### Hyperparameter Grid Search

The notebook includes a grid search over:

```text
UBM components: 8, 16, 32, 64
MAP relevance factor: 4, 8, 16, 32
```

Most tested configurations achieved good results. This suggests that the MFCC features are separable enough for the current dataset.

---

### EER and ROC

The notebook also computes:

- genuine scores,
- impostor scores,
- ROC curve,
- AUC,
- Equal Error Rate.

These are useful for understanding the recognition system beyond simple accuracy.

---

## Dependencies

### MATLAB

MATLAB is used for the from-scratch MFCC extraction and feature export.

Required MATLAB functions include:

- `audioread`
- `fft`
- `hamming`
- `dct`

Depending on the MATLAB version, `hamming` and `dct` may require additional toolboxes such as the Signal Processing Toolbox.

---

### Python

| Package | Purpose |
|---------|---------|
| `numpy` | Numerical computation |
| `scipy` | Loading MATLAB `.mat` files |
| `scikit-learn` | Gaussian Mixture Models, scaling, PCA, metrics |
| `matplotlib` | Plotting |
| `seaborn` | Statistical visualization |
| `librosa` | Audio loading and MFCC extraction |
| `sounddevice` | Microphone recording |

Install the dependencies using:

```bash
pip install numpy scipy scikit-learn matplotlib seaborn librosa sounddevice
```

---

## Important Notes

- This system is currently designed for closed-set speaker identification.
- Closed-set means the test speaker must be one of the enrolled speakers.
- MATLAB stores features as `39 × M`.
- Python uses features as `M × 39`.
- The MATLAB MFCC pipeline and the `librosa` MFCC pipeline may not give exactly identical numerical values.
- The current dataset is small, so the result should not be treated as a large-scale benchmark.
- For real-world use, the system should be tested with more speakers and more recording conditions.

---

## References

1. D. A. Reynolds, T. F. Quatieri, and R. B. Dunn,  
   “Speaker Verification Using Adapted Gaussian Mixture Models,”  
   Digital Signal Processing, vol. 10, no. 1–3, pp. 19–41, 2000.

2. S. B. Davis and P. Mermelstein,  
   “Comparison of Parametric Representations for Monosyllabic Word Recognition in Continuously Spoken Sentences,”  
   IEEE Transactions on Acoustics, Speech, and Signal Processing, vol. 28, no. 4, pp. 357–366, 1980.

3. J.-L. Gauvain and C.-H. Lee,  
   “Maximum a Posteriori Estimation for Multivariate Gaussian Mixture Observations of Markov Chains,”  
   IEEE Transactions on Speech and Audio Processing, vol. 2, no. 2, pp. 291–298, 1994.
```