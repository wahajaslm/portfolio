---
visibility: public
use_for_ai: true
title: "Beatnik — Gesture-Controlled OSC/MIDI Glove"
summary: "Hand-gesture OSC glove with piezo/FSR sensing, active analog filtering, and DMA-driven MCU output. Interfaced with Ableton Live."
year: "Prototype"
format: "Project Archive"
code: "HCI-05"
cover_image: "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1000&auto=format&fit=crop"
tags: [gesture_control, osc, midi, sensors, embedded, dma, piezo_sensing, stm32, c, ableton_live]
article_slug: "beatnik-osc-glove"
---

# BEATNIK – Gesture-Controlled OSC/MIDI Glove  

## Overview

BEATNIK is a wearable glove-based controller that converts gestures and finger movements into:

- **OSC (Open Sound Control) messages**, and  
- **MIDI notes / MIDI Control Change messages**

It enables expressive performance control for:

- synthesizers  
- DAWs (Ableton, Logic, FL Studio)  
- modular synthesis environments (Max/MSP, SuperCollider, Pure Data)  
- VST plugins and live performance rigs  

The system integrates:

- flex sensors  
- IMU/accelerometer  
- embedded C firmware  
- OSC/MIDI communication  
- host-side sound engines  

Its goal is to provide **fluid, human, gestural music control** that traditional knobs/sliders cannot offer.

## Problem Statement

Most music controllers:

- are discrete  
- rely on buttons/knobs  
- lack expressive nuance  
- feel mechanical rather rather than human  

BEATNIK enables **natural, continuous, real-time control** using gestures.

Challenges solved:

- stable sensor readings under noise  
- low-latency gesture detection  
- expressive mapping to MIDI/OSC  
- intuitive interface for performers  

## System Architecture

### Hardware Layer
- Flex sensors (1 per finger)
- IMU/accelerometer for tilt / roll / shake
- Microcontroller (Arduino/Teensy class)

### Signal Processing Layer
- ADC sampling  
- Exponential smoothing to reduce jitter  
- Gesture classification  
- Noise thresholding  

### OSC & MIDI Output Layer
- OSC message packer  
- MIDI note generator  
- MIDI CC mapping  
- Configurable output mode (OSC-only, MIDI-only, hybrid)

### Host System
- DAW or synthesis environment that receives OSC or MIDI  

## OSC Messaging (Full Technical Detail)

OSC messages follow a structured namespace:

```
/beatnik/finger1      float 0.0–1.0
/beatnik/finger2      float 0.0–1.0
/beatnik/finger3      float 0.0–1.0
/beatnik/finger4      float 0.0–1.0
/beatnik/finger5      float 0.0–1.0

/beatnik/tilt         float -1.0–1.0
/beatnik/roll         float -1.0–1.0
/beatnik/shake        float 0–127
```

### OSC Uses
- Flex → filter cutoff, LFO depth, amplitude envelope  
- Tilt → pitch bend or spatialization  
- Shake → percussive trigger or FX burst  

### OSC Rate
- Sent at **30–60 Hz** for smooth motion without overloading host apps  

## MIDI Note + CC Messaging (Full Detail)

The glove supports three musical modes:

### MIDI Note Triggering
Each finger can trigger notes:

| Finger Gesture | Threshold | MIDI Output |
|----------------|-----------|-------------|
| Index bent     | > bend_t  | NOTE ON 60 velocity=X |
| Index released | < bend_t  | NOTE OFF 60 |
| Middle bent    | > bend_t  | NOTE ON 62 |
| Ring bent      | …         | NOTE ON 64 |

### Velocity Calculation
```
velocity = clamp( (Δfinger_bend / Δt) * 127 )
```

This creates **human feel** rather than fixed velocity.

### MIDI CC Control (Continuous Control)

Recommended mappings:

```
finger1 → CC74 (Filter Cutoff)
finger2 → CC1  (Mod Wheel / Vibrato)
finger3 → CC11 (Expression)
tilt    → CC10 (Pan)
shake   → CC5  (Portamento or FX depth)
```

Gestures map to CC values **0–127**.

### Pitch Bend
Tilt angle → bend value:

```
pitchbend = map(tilt, -1.0..1.0 → -8192..8191)
```

### Supported Output Modes

| Mode | Behavior |
|------|----------|
| OSC-only | Continuous OSC messages only |
| MIDI-only | Notes + CC only |
| Hybrid | Sends both OSC + MIDI for experimental rigs |

## Implementation Details

### Firmware (C)
- ADC sampling loop  
- Normalization of sensor values  
- Exponential smoothing filter  
- State machine for gesture detection  
- OSC packing (Lightweight OSC library)  
- MIDI over USB or serial  

### Latency Optimization
- Non-blocking timing loops  
- Minimal filtering delay (<5 ms)  
- Efficient OSC batching  
- USB MIDI for ultra-low latency  

### Host Setup
Compatible with:
- Ableton Live (via virtual MIDI port or OSC bridge)
- Max/MSP patches
- SuperCollider SynthDefs
- Logic Pro (MIDI layer)
- Pure Data & VCV Rack (OSC)

## Results

- Very expressive modulation (filter/fx sweeps)  
- Stable continuous CC values  
- Clean note triggering  
- <20 ms total end-to-end latency  
- Natural gestural performance experience  

## Skills Demonstrated

- Embedded C  
- Sensor fusion  
- Real-time filtering  
- OSC protocol implementation  
- MIDI generation  
- Human–computer interaction  
- Hardware–software integration  

## Narration / Reflection

This project showed me how raw movement becomes **musical performance**.

I learned that:

- sensor data is noisy and must be shaped,  
- expressiveness requires continuous control,  
- OSC and MIDI each offer unique strengths,  
- real-time systems must feel responsive, not only correct.

BEATNIK taught me to think from the **performer's perspective**, not just the engineer’s.  
It shaped my sensitivity to latency, gesture dynamics, and expressive control — skills that later influenced
my DSP and audio engineering work.

---
