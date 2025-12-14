---
visibility: public
use_for_ai: true
title: "Vidi — Low-Latency Pitch Tool"
summary: "Pitch detection and shifting across parametric and non-parametric methods. Built with iOS Core Audio, vDSP/Accelerate, and MIDI Mapping."
year: "Audio Tool"
format: "Project Archive"
code: "APP-03"
cover_image: "https://images.unsplash.com/photo-1485846234645-a62644f84728?q=80&w=1000&auto=format&fit=crop"
tags: [audio, speech, dsp, pitch, core_audio, vDSP, ios, swift, midi, latency_optimization]
article_slug: "vidi"
---

# VIDI — Low-Latency, Reliable Pitch Detection & Pitch-Shifting Tool  

## Overview

**VIDI** is a real-time pitch detection and pitch-shifting tool designed for musicians who need  
**fast, stable, low-latency pitch tracking** — even in noisy rooms or during rapid melodic passages.

Instead of relying on a single pitch detection method, VIDI fuses multiple DSP techniques to provide
confidence-weighted pitch estimates that:

- **lock quickly**,  
- **don’t drift**,  
- **remain stable under noise**, and  
- **produce natural, musical pitch shifts** without chipmunk artifacts.

It was built with **Core Audio** and **vDSP**, optimized for **mobile-class hardware** with strict 
latency and performance constraints.

## Problem Statement

Musicians need pitch tools that work **live**, not only in ideal studio conditions.  
Most existing systems fail in at least one area:

- too sensitive to noise  
- unstable on fast notes  
- slow lock-in time  
- robotic or chipmunk-like pitch shifts  
- MIDI output that drifts under load  

VIDI solves these by combining multiple pitch algorithms and stabilizing them through DSP fusion.

## System Architecture

```
Incoming Audio  
      ↓  
Frame Processing (Core Audio)  
      ↓  
Parallel Pitch Estimators (AMDF / Autocorrelation / HPS)  
      ↓  
Confidence Fusion Engine  
      ↓  
Formant-Aware Pitch Shifting  
      ↓  
Low-Latency MIDI Output  
```

## Key DSP Components

### Parallel Pitch Detection Engines

VIDI runs three pitch detectors concurrently:

#### AMDF (Average Magnitude Difference Function)
- Excellent for fast passages  
- Good resolution for monophonic signals  
- Works well in noisy conditions  

#### Autocorrelation
- Stable periodicity detection  
- Helps reduce octave errors  
- Provides reliable fundamentals  

#### Harmonic Product Spectrum (HPS)
- FFT-based approach using harmonic reinforcement  
- Useful for strong harmonic structures  
- Helps refine ambiguous pitch regions  

### Confidence-Weighted Fusion

Results are combined using a confidence score per method:

- consistency across methods  
- signal periodicity  
- harmonic energy distribution  
- AMDF minima stability  
- autocorrelation peak clarity  

The fusion engine outputs a **single, stable pitch value** resistant to noise and instability.

## Low-Latency Architecture

### Core Audio + vDSP Pipeline

VIDI uses:

- **Core Audio render callbacks** for sub-10 ms frame processing  
- **vDSP FFTs** for spectral methods  
- Hot loop optimizations:
  - inlining critical operations  
  - avoiding unnecessary heap allocations  
  - tight C loops for AMDF  
  - vectorized operations where beneficial  

### Performance Targets

- **Frame size:** 64–128 samples  
- **Latency budget:** configurable, typically 10–20 ms end-to-end  
- **CPU footprint:** optimized for mobile processors  

## Formant-Aware Pitch Shifting

Standard pitch shifting introduces:

- chipmunk vocals  
- unnatural brightness  
- timbre distortion  

VIDI avoids this with:

- **formant tracking**  
- **spectral envelope estimation**  
- **formant-preserving warping**  
- blending PSOLA-like and phase-vocoder concepts  

Result: **natural, human-sounding pitch shifts**, even at large intervals.

## MIDI Output Engine

VIDI generates highly stable MIDI output:

- configurable smoothing  
- hysteresis to reduce jitter  
- velocity modeling based on onset detection  
- guarantee of no timing drift under CPU load  

Compatible with:

- Ableton Live  
- Logic Pro  
- FL Studio  
- Max/MSP  
- Hardware synthesizers  

## Results

VIDI delivered:

- **fast pitch lock-in**  
- **stable tracking** even with noise  
- **natural pitch shifts** without artifacts  
- **low latency**, suitable for live use  
- **accurate MIDI output**  

Musicians rated it as:

- predictable  
- responsive  
- expressive  
- trustworthy in live performance  

## Skills Demonstrated

- DSP algorithm design  
- Multi-method pitch estimation  
- Confidence scoring & fusion  
- vDSP FFT optimization  
- Core Audio real-time pipelines  
- Formant-preserving pitch shifting  
- MIDI integration  
- Low-latency engineering  
- Performance optimization  

## Narration / Reflection

VIDI was a significant step in understanding **real-time DSP under real-world constraints**.  
I learned how:

- AMDF + autocorrelation + HPS complement one another  
- confidence fusion stabilizes noisy estimates  
- low-latency budgets drive architectural choices  
- musicians value *feel* as much as technical accuracy  

VIDI fused **DSP theory**, **musical sensitivity**, and **engineering practicality**, shaping how I approach
audio systems, performance tuning, and perceptually meaningful DSP.

---
