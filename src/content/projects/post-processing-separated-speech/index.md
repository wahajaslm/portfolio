---
visibility: public
use_for_ai: true
title: "Post-Processing Separated Speech"
summary: "Reconstructed damaged time-frequency components of separated speech using bandwidth extension. Analyzed LPC Analysis/Synthesis, STFT & Pitch Estimation, and Pole/Zero LPC Envelopes."
year: "Master Thesis"
format: "Project Archive"
code: "DSP-01"
cover_image: "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=1000&auto=format&fit=crop"
tags: [speech, dsp, bandwidth_extension, lpc, excitation, speech_enhancement, stft, python, matlab, research]
article_slug: "post-processing-separated-speech"
---

# Master Thesis — Speech Bandwidth Extension Using Non-Linear Post-Processing  

## Overview

This thesis focused on reconstructing **wideband speech** from narrowband (telephone-band) input
using **non-linear post-processing**, **excitation modelling**, and **spectral envelope reconstruction**.
The goal was to increase perceived bandwidth, restore brightness, and improve naturalness **without**
requiring changes to the encoder or any side information.

The work brought together:

- Digital signal processing theory (LPC, source–filter models)
- Practical system design
- MATLAB & Python prototyping
- Perceptual audio evaluation and tuning
- Iterative refinement based on listening tests and spectral analysis

## Problem Statement

Traditional narrowband speech (0–4 kHz) loses:

- High-frequency harmonics  
- Brightness and “air”  
- Natural articulation cues  
- Wideband timbral characteristics  

The challenge is reconstructing plausible high-band components **from missing information**, not noisy
information. This is fundamentally an **ill-posed inverse problem**, requiring:

- Excitation generation  
- Envelope reconstruction  
- Stability against artifacts  
- Low computational cost  

Goal:  
Produce **wideband-like speech** that is perceptually convincing and spectrally coherent.

## System Architecture

The thesis designed a processing chain consisting of:

### Narrowband Analysis
- Pre-emphasis  
- Windowing  
- LPC analysis (10–14th order)  
- Extraction of the excitation signal  

### Excitation Modelling
Tested approaches included:

- Non-linear expansion  
- Odd/even harmonic generation  
- Sign-preserving power functions  
- Spectral folding  
- Blended excitation shaping  

The final system used **non-linear excitation expansion** with a **high-band shaping filter**.

### Envelope Reconstruction
Methods explored:

- LPC envelope extrapolation  
- High-band envelope smoothing  
- Adaptive energy matching  
- Band-tilting adjustments  

### Synthesis
- Excitation filtering using reconstructed LPC coefficients  
- Overlap–add synthesis  
- Envelope smoothing and final spectral correction  

## Block Diagram (Textual)
Narrowband Speech
↓
Analysis
(LPC, excitation)
↓
Non-linear Excitation Expansion
↓
High-band Spectral Shaping
↓
Envelope Reconstruction
↓
Synthesis
↓
Enhanced Wideband-like Speech

## Implementation Details

### MATLAB Prototyping
- LPC extraction (autocorrelation & Burg methods)
- Excitation expansion experiments
- Envelope smoothing filters
- Spectral envelope visualization
- Objective metrics:
  - log-spectral distance (LSD)
  - harmonic envelope deviation

### Python Experiments
- Rapid testing of excitation functions
- Plotting envelope differences
- Generating spectrograms and comparison views
- Automating batch evaluation sets

## Evaluation Strategy

### Objective Measures
- High-band energy reconstruction accuracy  
- Envelope shape similarity  
- Temporal smoothness  

### Perceptual Evaluation
Performed **A/B and A/B/X listening tests** on:

- Male + female speech  
- Different languages  
- Varied articulation patterns  
- Clean vs. challenging content  

Artifacts tracked and tuned:

- Metallic ringing  
- Whistle-like tones  
- Synthetic “hiss”  
- Harsh high-frequency energy  
- Energy mismatch between narrowband and high-band  

**Perceptual testing was essential** — many methods that looked good numerically produced 
unacceptable artifacts during listening.

## Key Results

- Reconstructed high-band content **significantly improved** perceived brightness and clarity.  
- Non-linear excitation + spectral shaping produced stable and natural-sounding results.  
- High-band envelope reconstruction matched reference wideband behavior well.  
- Objective and subjective evaluations aligned closely after tuning.

## Skills Demonstrated

### DSP Expertise
- LPC modelling  
- Excitation generation  
- Non-linear processing  
- Envelope shaping  
- Filter design  
- Time–frequency analysis  

### Prototyping Skills
- MATLAB algorithm development  
- Python batch experiments + visualization  
- Handling multi-file evaluation pipelines  

### Perceptual Engineering
- Systematic listening test methodology  
- Artifact identification  
- Iterative tuning based on perceptual + spectral evidence  

### Research & Documentation
- Reproducible experiments  
- Clear reporting of results  
- Scientific and engineering communication  

## Narration / Personal Reflection

This thesis shaped my understanding of audio engineering at a deep level.  
I learned that:

- A mathematically “correct” algorithm may still sound terrible.  
- Spectral plots, excitation behavior, and envelopes must align with what listeners perceive.  
- Perceptual tuning is a **core part of DSP**, not an afterthought.  

The project taught me to think simultaneously like a:

- **scientist** (theory, modelling)  
- **engineer** (system design, prototyping)  
- **listener** (perception, artifacts, tuning)  

This balance between **math, engineering, and human hearing** continues to define how I approach
audio, DSP, and media systems today.

---

