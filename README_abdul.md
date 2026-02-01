# 🎙️ An Automatic Speaker Recognition System

A **classical Digital Signal Processing (DSP)** based implementation of an  
**Automatic Speaker Recognition System** using **MFCC** feature extraction and  
**Vector Quantization (VQ – LBG algorithm)** for speaker modeling.

This project focuses on **fundamental signal processing concepts** that form the
foundation of modern speaker recognition systems.

---

## 📌 Project Overview

Speaker recognition is the task of identifying **who is speaking** based on their voice.
This project implements a **text-independent speaker identification system**, meaning
the system recognizes the speaker **regardless of the spoken content**.

The approach used here is classical, interpretable, and lightweight — making it ideal
for learning and academic evaluation.

---

## 🧠 System Architecture (High-Level Pipeline)

```text
Speech Signal
     ↓
Pre-Emphasis
     ↓
Framing & Windowing
     ↓
FFT
     ↓
Mel Filter Bank
     ↓
Log Energy
     ↓
DCT
     ↓
MFCC Features
     ↓
Vector Quantization (LBG)
     ↓
Speaker Model (Codebook)
     ↓
Distance Measurement
     ↓
Speaker Identification
```
## 🔁 Processing Flowchart

flowchart TD
    A[🎤 Audio Input (.wav)] --> B[Pre-Emphasis]
    B --> C[Framing]
    C --> D[Windowing (Hamming)]
    D --> E[FFT]
    E --> F[Mel Filter Bank]
    F --> G[Log Energy]
    G --> H[DCT]
    H --> I[MFCC Feature Vectors]
    I --> J[Vector Quantization (LBG)]
    J --> K[Speaker Codebooks]
    K --> L[Euclidean Distance]
    L --> M[🎯 Speaker Identified]

---

## 🧪 Project Phases

### 1️⃣ Data Collection
- Record speech samples from multiple speakers  
- Use the same microphone and environment  
- Audio format: `.wav`


---

### 2️⃣ Preprocessing
Applied to raw speech signals:
- Pre-emphasis (boost high frequencies)
- Framing (20–25 ms)
- Overlap (~10 ms)
- Hamming window to reduce spectral leakage

---

### 3️⃣ Feature Extraction – MFCC 🧩
Mel-Frequency Cepstral Coefficients (MFCC) represent speech in a compact,
perceptually meaningful form.

**Typical configuration:**
- FFT size: 256 / 512
- Mel filter banks: 26
- MFCC coefficients: 12–13

**Output:**

MFCC Matrix → [Number of Frames × 13]

---

### 4️⃣ Speaker Modeling – Vector Quantization 📦
- Uses the **Linde–Buzo–Gray (LBG)** algorithm  
- Clusters MFCC feature vectors  
- Cluster centroids form a **speaker codebook**  
- Typical codebook size: 16–64  

Each speaker is represented by **one codebook**.

---

### 5️⃣ Speaker Identification 🎯
For a test speech sample:
- Extract MFCC features  
- Compute distance to each speaker’s codebook  
- Average the distortion  
- Identify the speaker with the **minimum distance**

**Distance metric used:**
- Euclidean Distance

---

## 📊 Performance Evaluation
- Speaker identification accuracy
- Confusion analysis
- Effect of codebook size
- Error sources (noise, channel mismatch)

---

## 🛠️ Tools & Technologies
- MATLAB / Python
- NumPy, SciPy
- Librosa (optional)
- Git & GitHub

---

## 🚀 Future Improvements
- Cepstral Mean Normalization (CMN)
- Delta and Delta-Delta MFCCs
- Gaussian Mixture Models (GMM)
- Deep learning approaches (x-vectors)

---

## 📚 Key References
- Davis & Mermelstein (1980) – MFCC
- Linde, Buzo & Gray (1980) – Vector Quantization
- Rabiner & Schafer – Speech Signal Processing
- Reynolds (1995) – Distance Measures in Speaker Recognition

---

## 👥 Team Members
- Heshan Ranasinghe  
- Mokshan Colombage  
- Abdul Rahman  

---

## ⭐ Why This Project?
This project builds strong intuition in:
- Digital Signal Processing
- Speech feature extraction
- Pattern recognition fundamentals

*Classical systems may be old, but they teach ideas that never expire.*
