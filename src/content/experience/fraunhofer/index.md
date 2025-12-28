---
visibility: public
use_for_ai: true
tags: [audio, dsp, codec, streaming, c, c++, python, ci_cd, critical_listening]
---

# Fraunhofer IIS – Audio & DSP Engineer

## Role Summary

### Senior Engineer – Audio Codec Development (Mar 2023 – Present)
- Led the technical design and implementation of new codec tools from research to deployment
- Architectural contributions related to low-latency, adaptive streaming, and scalable encoding frameworks
- Performance and complexity optimization on ARM and x86_64 platforms
- Integration and validation within FFmpeg and Windows Media Foundation pipelines
- Long-term maintenance, testing, and regression analysis for production codebases

### Scientific Researcher – Audio Signal Processing (Apr 2018 – Feb 2023)
At Fraunhofer IIS, I worked as an Audio/DSP Engineer on tools and components around modern audio
codecs such as MPEG-H 3D Audio and xHE-AAC. The work combined:

- **C-based DSP and systems engineering**
- **Modern C++ integration and tooling**
- **Python-based evaluation and automation**
- **Critical listening and artifact analysis**
- **Streaming-oriented validation** of encoder behavior in ecosystems used by major platforms like  
  **Netflix, Amazon Music, YouTube, and Microsoft** (public ecosystem level, not confidential).

This role forced me to think end-to-end: from a line of C code in a DSP block to how that change
affects perceived quality in a streaming scenario.

---

## Key Responsibilities (Non-Confidential)

### 1. DSP & System-Level Development in C

- Implemented and maintained performance-critical C modules used in internal encoder / toolchain flows.
- Worked on signal-path logic, buffer management, state handling, and configuration-dependent behavior.
- Ensured stability and determinism across multiple operating modes and platforms.

### 2. Modern C++ Tools & Media Integration (MFT)

- Developed C++ utilities and test applications around encoders/decoders.
- Integrated components into **Microsoft Windows Media Foundation (MFT)** to simulate realistic playback /
  processing pipelines.
- Built small frameworks / harnesses for automated end-to-end tests in media-like environments.

### 3. Streaming-Oriented Encoder Validation

- Supported test flows that mirror **streaming use cases**:
  - ABR-style bitrate ladders
  - Segment-based encoding behavior
  - Consistency across renditions and presets
  - Handling of metadata / loudness / configuration changes
- Participated in internal evaluations that reflect usage by major streaming platforms  
  (e.g. Netflix, Amazon Music, YouTube, Microsoft – as publicly associated with these codecs).

### 4. Python Automation & Evaluation Frameworks

- Wrote Python scripts to:
  - run batch encoder evaluations,
  - compare different builds / presets,
  - generate plots and numerical summaries,
  - manage input/output sets for regression testing.
- Automated repetitive tasks (e.g. multiple bitrate runs, content sets, preset combinations) to make
  evaluation more systematic and less manual.

### 5. CI/CD & Engineering Operations

- Contributed to **GitLab CI** pipelines to ensure regular automated builds and tests.
- Used Bash/Python glue to orchestrate multi-stage test jobs and artifact handling.
- Helped improve reliability of the evaluation pipeline over time.

---

## Critical Listening & Perceptual Analysis

### 6. Critical Listening & Artifact Detection

- Spent **hundreds of hours** in structured listening sessions across speech, music and complex content.
- Developed the ability to detect and classify artifacts such as:
  - pre-echo
  - transient smearing
  - metallic ringing / “metallic” voices
  - spectral holes / narrowband notches
  - high-band / low-band tone mismatch
  - roughness / hiss / “synthetic” timbre
  - stereo image instability or collapse
- Learned to connect what I heard to what I saw in:
  - spectrograms (Adobe Audition, Python/MATLAB plots),
  - waveforms,
  - difference signals and diagnostic views.

### 7. Audio Analysis Tools & Workflow

Regularly used:

- **Adobe Audition** – spectrograms, transient analysis, zooming into problem regions.
- **FFmpeg** – transcoding, re-encoding, ABR ladder generation, waveform extraction, segmenting.
- **MediaInfo** – checking codec configuration, bitrate, channel layouts, and container info.
- **Python/MATLAB** – custom plots (LPC envelopes, spectral envelopes, error curves, etc.).
- Internal waveform / spectrum tools to localize issues and verify fixes.

This toolchain became my standard way to **triangulate** issues: listen → visualize → inspect metadata →
adjust DSP logic or configuration.

---

## Achievements

- **Perceptual Quality Safeguard**  
  Identified subtle artifacts in internal evaluation runs (for specific content types and bitrates) that were
  not obvious from metrics alone, helping prevent regressions from progressing further.

- **Streaming-Aligned Testing**  
  Contributed to testing setups that better reflected how encoders behave in streaming-style usage  
  (bitrates, segments, switching scenarios), improving confidence for ecosystem deployments involving
  platforms like Netflix, Amazon Music, YouTube, and Microsoft.

- **Evaluation Pipeline Reliability**  
  Helped stabilize Python-driven evaluation flows and CI jobs so that larger sets of tests could run more
  reliably without manual babysitting.

- **Cross-Domain Intuition**  
  Built strong intuition linking:
  - mathematical changes in DSP modules,
  - visual patterns in spectrograms / plots,
  - and final perceptual outcomes.

---

## Narration / Stories

### Story – When a Small Change Became a Big Artifact

A small change in one block produced a faint but irritating metallic ringing only on specific female
vocals with strong high-frequency content. On paper the change looked harmless; metrics hardly moved.
But listening exposed a clear regression. Looking at spectrograms showed a narrowband spike that lined
up exactly with what I heard. That moment reinforced a key lesson: **perception is the final judge**, not
just numbers.

### Story – Thinking Like a Streaming Engineer, Not Just a DSP Engineer

Working on streaming-oriented tests forced me to care about:
- how the encoder behaves across an ABR ladder,
- what happens when bitrates switch,
- how metadata and loudness are preserved,
not just how “clean” a single coded file sounds under ideal conditions. That shifted my mindset from
pure DSP to **system-level media engineering**.

---