---
visibility: public
use_for_ai: true
title: "Beatnik — Gesture-Controlled OSC/MIDI Interface"
summary: "Design and implementation of a wireless gesture controller using mbed LPC1768, DMA-driven acquisition, and active signal conditioning."
year: "Prototype"
format: "Technical Archive"
code: "HCI-05"
cover_image: "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1000&auto=format&fit=crop"
tags: [gesture_control, osc, midi, sensors, embedded, dma, active_filtering, c++]
article_slug: "beatnik-osc-glove"
---

## Demo Video

<video controls muted playsinline class="project-video" style="width: 100%; border-radius: 8px; margin-bottom: 2rem;">
  <source src="/portfolio/projects/beatnik-osc-glove/assets/beatnik.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

## Abstract

This project details the development of a wearable interface designed to translate biocontinual hand gestures into Open Sound Control (OSC) and MIDI messages. The system utilizes a custom sensor array, an mbed LPC1768 microcontroller, and a Direct Memory Access (DMA) acquisition architecture to achieve low-latency (<10ms) performance suitable for real-time musical expression.

---

## System Overview

The Beatnik system acts as a translation layer between physical gesture and digital sound synthesis. Unlike discrete controllers (keyboards, buttons), it provides continuous multi-dimensional control data.

### Architecture Block Diagram:
```
[Flex Sensors] -> [Voltage Divider/Filter] -> [ADC (LPC1768)]
                                                  | (DMA Transfer)
                                            [Memory Buffer]
                                                  |
                                            [DSP & Logic]
                                                  |
                                            [OSC Packetizer]
                                                  | (UDP)
                                            [Host Computer]
```

---

## Hardware Implementation

The physical interface consists of a fabric glove integrated with variable resistance flex sensors (Spectra Symbol) along the fingers and an Inertial Measurement Unit (IMU) on the dorsal side.

### Signal Conditioning
Raw flex sensors exhibit significant noise and non-linearity. To mitigate this, a hardware interface circuit was designed:
*   **Voltage Divider:** Converts resistance change to voltage (0-3.3V range).
*   **Active Low-Pass FIltering:** A first-order RC filter is applied before the ADC input to reject high-frequency mechanical noise and electromagnetic interference.

<div class="gallery-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin: 2rem 0;">
  <img src="/portfolio/projects/beatnik-osc-glove/assets/1.png" alt="Hardware fabrication" loading="lazy" style="border-radius: 8px;" />
  <img src="/portfolio/projects/beatnik-osc-glove/assets/3.png" alt="Circuit schematic detail" loading="lazy" style="border-radius: 8px;" />
</div>

---

## Firmware & Signal Processing

The firmware is developed in C++ on the mbed platform (ARM Cortex-M3). A critical design constraint was keeping the main execution loop non-blocking to maintain network throughput.

### DMA-Driven Acquisition
Standard ADC polling introduces CPU overhead and timing jitter. This implementation utilizes the LPC1768's **GPDMA (General Purpose Direct Memory Access)** controller. The ADC is configured in "Burst Mode," continuously sampling the sensor channels and writing results directly to a circular memory buffer. This decouples sampling from processing.

```cpp
// ADC Burst Mode Configuration with DMA
void setup_dma() {
    dma.Setup( conf ); 
    dma.Enable( conf );
    LPC_ADC->ADCR |= (1UL << 16); // Enable Burst Mode
    // The hardware now manages sampling independently of the CPU
}
```

### Digital Filtering
To further stabilize the signal without introducing perceptible lag, a two-stage software filter is applied:
1.  **Hysteresis:** Prevents oscillation around threshold points.
2.  **Exponential Smoothing:** applied as `y[n] = α * x[n] + (1-α) * y[n-1]`. An alpha value of 0.3 was found to balance potential latency against jitter reduction.

<img src="/portfolio/projects/beatnik-osc-glove/assets/4.png" alt="Sensor calibration data" loading="lazy" style="width: 100%; border-radius: 8px; margin: 2rem 0;" />

---

## Communication Protocol

The system outputs **Open Sound Control (OSC)** over UDP. OSC was selected over MIDI 1.0 for its high-resolution floating-point support.

*   **MIDI Resolution:** 7-bit (0-127). Insufficient for smooth filter cutoffs.
*   **OSC Resolution:** 32-bit Float. Eliminates "zipper noise" (audible stepping artifacts) during slow sweeps.

### Namespace Structure
```
/beatnik/finger/[id]  <float> (0.0 - 1.0)
/beatnik/imu/pitch    <float> (-1.0 - 1.0)
/beatnik/imu/roll     <float> (-1.0 - 1.0)
```

---

## Performance Metrics

*   **Latency:** <10ms end-to-end (sensor to OSC packet transmission).
*   **Sample Rate:** Sensors sampled at 100Hz; Network packets transmitted at 60Hz.
*   **Stability:** Active filtering reduced signal variance by approx. 40% compared to raw input.

<div class="gallery-grid" style="margin-top: 2rem;">
  <img src="/portfolio/projects/beatnik-osc-glove/assets/2.png" alt="Prototype bench testing" loading="lazy" style="border-radius: 8px;" />
  <img src="/portfolio/projects/beatnik-osc-glove/assets/5.png" alt="Final assembly" loading="lazy" style="border-radius: 8px;" />
</div>
