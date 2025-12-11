# Building a Reliable Pitch Tool for Musicians

I wanted a pitch detector that wouldn’t buckle under noisy rooms or fast passages. Vidi blends parametric and non-parametric methods so it locks quickly and stays musical.

⸻

Key moves:
- Ran AMDF, autocorrelation, and harmonic product spectrum in parallel, then fused results with confidence scoring.
- Used Core Audio and vDSP for low-latency FFTs; profiled hotspots and inlined critical loops to stay responsive on mobile hardware.
- Added formant-aware pitch shifting to avoid chipmunk vocals.
- Tuned MIDI output with configurable latency budgets so players could route into DAWs without drift.

Outcome: a portable pitch utility musicians could trust live—fast locks, stable output, and shifts that sound human instead of robotic.
