---
visibility: public
use_for_ai: true
title: "Laser Harp — Optical Motion-Based Musical Instrument"
summary: "Laser-triggered MIDI controller using photodiodes and serial comms to drive performance hardware. Built on PIC Microcontroller."
year: "Instrument"
format: "Project Archive"
code: "INS-06"
cover_image: "https://images.unsplash.com/photo-1535905557558-afc4877a26fc?q=80&w=1000&auto=format&fit=crop"
tags: [laser, optics, embedded, sensors, musical_interface, midi, photodiodes, c, analog_filtering, calibration]
article_slug: "laser-harp"
---
---

# Laser Harp — Optical Motion-Based Musical Instrument  
### A No-Touch Interactive Music System Using Laser Beams + Sensor Interrupts

---

## 1. Overview

The **Laser Harp** is an optical musical instrument where each “string” is a **beam of laser light**.  
When a performer moves their hand through a beam, the interruption is detected and translated into a:

- **MIDI note**,  
- **OSC message**, or  
- **control signal**  

depending on the chosen output mode.

The project combines:

- real-time embedded sensing  
- optical alignment and calibration  
- noise filtering  
- musical mapping logic  
- gestural control concepts  

---

## 2. Problem Statement

Physical harps require string plucking.  
The goal here was to design a **touchless**, visually striking instrument that:

- reacts instantly to hand motion  
- avoids false triggers from ambient light  
- maps gestures to musical notes cleanly  
- is playable in low and high lighting conditions  

Challenges solved:

- optical noise from room lighting  
- sensor threshold calibration  
- fast detection of beam interruption  
- avoiding note flicker and retriggers  
- mapping multiple beams to a musical scale  

---

## 3. System Architecture

### **1. Optical Beam System**
- Multiple laser diodes positioned vertically  
- Photodiodes or LDRs aligned opposite each laser  
- A constant laser → photodiode reading indicates “beam intact”  
- A drop in sensor voltage indicates “beam broken”  

### **2. Signal Conditioning**
To create stable digital-like signals:

- Analog low-pass filters  
- Comparator circuits for thresholding  
- Pull-up/pull-down stabilization  
- Shielding to reduce ambient noise  

### **3. Embedded Controller**
A microcontroller (Arduino/Teensy-level) handled:

- Reading photodiode outputs  
- Applying debounce logic  
- State transitions (INTACT → BROKEN → INTACT)  
- Generating MIDI/OSC messages  

### **4. Output Layer**
Supports three modes:

#### MIDI Mode
- Note ON when the beam is broken  
- Note OFF when the beam is restored  
- Notes mapped to diatonic or chromatic scales  

#### OSC Mode
- OSC messages for:
  ```
  /laserharp/string1
  /laserharp/string2
  /laserharp/string3
  ```
- Useful for synthesis engines like Max/MSP, Pure Data, SuperCollider  

#### Hybrid Mode
- Both OSC + MIDI for advanced performance rigs  

---

## 4. Implementation Details

### 4.1 Photodiode Alignment
- Required precise beam-to-sensor alignment  
- Beam intensity adjusted to prevent oversaturation  
- Ambient light tested in different environments  

### 4.2 Embedded Logic (C)
The core loop ran at a stable frequency:

```c
if (sensor_value < threshold && state == INTACT) {
    trigger_note(string_id);
    state = BROKEN;
}

if (sensor_value > threshold && state == BROKEN) {
    release_note(string_id);
    state = INTACT;
}
```

Additional logic:

- Software debounce  
- Minimum-hold timers  
- Velocity/glide options  

### 4.3 MIDI Note Mapping
Two options:

#### **Fixed Scale**
```
Beam 1 → MIDI 60 (C4)
Beam 2 → MIDI 62 (D4)
Beam 3 → MIDI 64 (E4)
```

#### **Dynamic Mode**
Pitch determined by:

- hand height  
- beam index  
- external scale tables  

### 4.4 OSC Mapping
Example:

```
/harp/beam1 1   → beam broken
/harp/beam1 0   → beam restored
```

---

## 5. Results
- Intuitive and fun to play  
- Clear on/off triggering with minimal jitter  
- Visually striking, ideal for performance  
- Low latency due to efficient embedded design  

---

## 6. Skills Demonstrated
- Embedded C development  
- Analog/digital signal conditioning  
- Real-time state machine implementation  
- MIDI and OSC output design  
- Hardware prototyping  
- UX design for interactive instruments  

---

## 7. Narration / Reflection
Building a **touchless optical instrument** taught me how environmental factors, noise, timing stability, 
and physical placement influence real-time interaction.  

A laser harp only feels “correct” when triggering is instantaneous and stable.  
This reinforced principles that later shaped my DSP and audio engineering mindset:

- responsiveness matters  
- noise must be controlled  
- thresholds require tuning  
- UX is just as important as code  

---
