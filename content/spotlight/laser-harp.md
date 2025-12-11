# Turning Light into Music

Laser Harp: a theatrical MIDI controller where each beam is a string. Breaking a beam should trigger cleanly, not jitter under stage lights.

⸻

- Photodiodes with tuned thresholds and debouncing to ignore ambient light and hand jitters.
- PIC microcontroller scanning beams, mapping hits to MIDI notes, sending serial with low latency.
- Per-string velocity shaping and note-off handling so performances sound musical instead of binary.
- Tested under stage lighting to keep triggering consistent across venues.

Outcome: a playable, expressive laser instrument that turns big gestures into reliable MIDI for live sets.
