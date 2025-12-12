---
visibility: public
use_for_ai: true
title: "Parallel A/V Encoding Framework"
summary: "Concurrent FFmpeg + Python harness for ABR ladder experimentation with metrics and packaging."
tags: [ffmpeg, python, encoding, abr, metrics, bash, automation, packaging, streaming, monitoring]
---

# Building an ABR Encoding Lab

Needed: explore encoder variants quickly, measure quality, and assemble ladder candidates without hand-running FFmpeg every time. Built a Python + FFmpeg harness that ingests, fragments, runs variants, and spits out HLS/DASH artifacts with consistent logging.

⸻

Ingest & fragment:
- Auto-detect inputs, normalize tracks, segment into fragments with stable GOP alignment.
- Write fragment manifests so every variant keeps matching metadata.

Concurrent runs:
- Spawn FFmpeg workers across cores; track PIDs, timeouts, per-job temp dirs.
- Sweep GOP, tune/preset, RC mode, filters; produce fragmented MP4s per variant.
- Concatenate select fragments into short A/B clips for quick playback checks.

Metrics & packaging:
- Generate HLS/DASH playlists and ladders automatically from successful variants.
- Log VMAF, PSNR, bitrate, throughput; export CSVs to compare size vs. quality.
- Add guardrails: retries on transient failures, cleanup of orphaned processes, disk budget enforcement.

Outcome: faster ladder tuning with reproducible runs, instant A/B inspection, and clear quality/bandwidth trade-offs.
