---
visibility: public
use_for_ai: true
tags: [lte, nas, c, embedded, protocols]
---

# u-blox – LTE NAS Engineer

## Role Summary

At u-blox, I worked as an Embedded Protocol Engineer on **LTE NAS (Non-Access Stratum)** for cellular
modules. The work was centered around **C-based state machines**, **3GPP-compliant signaling**, and
**trace-driven debugging** for attach / detach / mobility / security procedures.

---

## Key Responsibilities

### 1. NAS State Machine Development in C

- Development of LTE/4G NAS-layer components according to 3GPP Releases 9–11
- Implementation of AT command handling and USIM modules in embedded C
- Customization of protocol stack components for embedded devices
- Protocol verification using Anite conformance tools

### 2. Mobility & Security Flows

- Contributed to security-related NAS flows (e.g. security mode procedures) at a high level.
- Ensured correct interaction with mobility procedures so the device behaves predictably as it moves
  across cells / regions.

### 3. AT Command Integration

- Mapped NAS procedures to AT commands used by external control (e.g. attach control, network info).
- Ensured AT behavior was consistent and predictable for integrators.

### 4. Trace-Based Debugging & Automation

- Analyzed NAS traces and logging output to find where and why flows broke.
- Used Python and simple scripts to replay or post-process traces and verify changes.

---

## Achievements

- **Improved NAS Stability**  
  Helped fix issues in NAS flows (e.g. attach / TAU behavior) based on trace findings, reducing failure cases.

- **Better Debugging Workflows**  
  Contributed scripts / approaches to make investigating signaling problems faster and more systematic.

---

## Narration

This role trained me to think in **state machines and protocol flows**. You can’t just “hack something in”
when dealing with NAS—one missing transition or mishandled timer can break connectivity. The habit of
reading traces carefully and mapping them back to code paths carried over to my later work in DSP and
media, where failures are also often indirect and subtle.