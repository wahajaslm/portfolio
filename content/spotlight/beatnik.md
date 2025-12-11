# From Gesture to Sound Without Lag

Beatnik is a glove-based OSC controller built for stage use. The rule was simple: if it feels laggy, it fails.

⸻

- Piezo + FSR sensing with active analog filtering before the ADC to tame noise.
- DMA-driven firmware loop to sample, smooth, and packetize sensor data without blocking.
- OSC messages shaped with velocity curves and dead zones so gestures stay expressive but stable.
- Tested against Ableton Live, tuning thresholds until performers stopped overshooting or jittering.

Outcome: gestural control that feels wired in—predictable, low-latency, and hard to mis-trigger. (Video: beatnik.mp4)
