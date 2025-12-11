# Bandwidth-Extension Post-Processing for Separated Speech

Master’s thesis tape: I tried to put back what TF masks took away—harmonics and detail that disappeared during source separation. The fix was to enhance the source–filter model (envelope + excitation) and resynthesize only the missing regions.

⸻

What I saw:
- Masks were suppressing weak speech along with interferers, leaving holes.
- LPC envelopes looked jagged; excitation inherited those artifacts and hurt perceived quality.

How I approached it:
- Analysis: 20 ms windows, 50% overlap, SRH for pitch/voicing, LPC and residual excitation per frame.
- Envelope: bandwidth expansion to pull poles off the unit circle and smooth the exaggerated peaks left by masking.
- Excitation: in time, removed lip radiation, did pitch-synchronous segmentation/averaging, used a gentle non-linearity to regenerate harmonics; in frequency, matched energy to the enhanced envelope and avoided aliasing/low-frequency overload.
- Synthesis: LPC synthesis with the enhanced pieces, but only in TF regions the mask had damaged.

Outcome: fewer spectral gaps, restored harmonic structure, and voiced segments that sounded more consistent—even without clean references for comparison.
