---
visibility: public
use_for_ai: true
tags: [wireless, sdr, matlab, multi_hop, cooperative_relays, ofdm, channel_modeling, warp, synchronization, link_budget]
summary: "WARP SDR multi-hop prototype with MATLAB tooling for packet tracing, channel modeling, and cooperative relay experiments."
---

# Multi-Hop Wireless Prototyping with WARP SDR  
### MATLAB Visualization, Real Experiments, and Cooperative Wireless Analysis

---

## 1. Overview

This project involved building a **research-grade multi-hop wireless prototyping system** using:

- **WARP SDR boards**  
- **MATLAB visualization tools**  
- **Custom data parsing and analysis scripts**

The aim was to allow researchers and students to **see and understand** how packets propagate through
multi-hop and cooperative communication networks under real wireless conditions.

The project unified:

- SDR experimentation  
- Wireless communication theory  
- Data visualization  
- MATLAB GUI development  
- Research methodology  

---

## 2. Problem Statement

Multi-hop wireless networks behave far differently in practice than in theoretical models.  
Difficulties include:

- unpredictable packet drops  
- timing misalignments between relays  
- asymmetric link quality  
- non-intuitive hop progression  
- unclear forwarding behaviors in coded vs. uncoded relays  

Raw logs alone make these behaviors **very hard to understand**.

Researchers needed:

✔ A visualization tool  
✔ Real-time or near-real-time feedback  
✔ Clear multi-hop path reconstruction  
✔ Comparison between forwarding schemes  

---

## 3. System Architecture

### **(1) WARP SDR Nodes**
Roles included:
- Source  
- One or more relays  
- Destination  

Nodes were configured to run experiments on cooperative relaying and multi-hop forwarding.

### **(2) Experiment Logging**
Each WARP node logged:
- packet arrivals  
- MAC/PHY timing  
- hop counts  
- relay decisions  
- RSSI / link quality indicators  

### **(3) MATLAB Data Interface**
A MATLAB module was written to:
- import logs  
- parse timestamps  
- synchronize node records  
- reconstruct packet paths  
- compute per-hop statistics  

### **(4) MATLAB Visualization GUI**
Custom GUI displayed:
- node topology  
- live or replayed packet flow  
- hop progression animation  
- RSSI bars  
- coded vs. uncoded performance difference  
- timelines and link behavior  

---

## 4. Implementation Details

### MATLAB Parsing Logic
- Parsed CSV/log files from each node  
- Mapped packet IDs → forwarding chain  
- Detected losses and duplicates  
- Aligned timestamps across nodes  
- Constructed directed graphs of packet movement  

### GUI Modules
- **Topology View**: nodes arranged visually, routing lines updated dynamically  
- **Hop Timeline**: how many hops a packet took across time  
- **RSSI Panel**: color-coded link quality  
- **Per-packet Playback**: replay packet propagation step-by-step  

### SDR Experiment Configuration
- Configured transmit power  
- Selected carrier frequency  
- Adjusted PHY parameters  
- Collected logs in controlled and noisy environments  

### Data Analysis Scripts
- computed per-hop success rates  
- compared coded vs uncoded forwarding reliability  
- plotted latency distributions  
- identified link asymmetries  

---

## 5. Key Findings

The visualization revealed behaviors that were NOT obvious from theory:

- **Relay–destination links behaved asymmetrically**, causing unexpected drops  
- **Coded forwarding improved robustness**, especially under low SNR  
- **Timing misalignment** between relays caused packet duplication or premature discard  
- **Hop count fluctuated dynamically**, depending on the wireless environment  

Graphs and animations provided immediate intuition about the multi-hop behavior that traditional logs
and equations could not convey.

---

## 6. Skills Demonstrated

### Wireless Communication Engineering
- Understanding of multi-hop and cooperative relaying  
- SDR hardware handling  
- Wireless measurement interpretation  

### MATLAB Engineering
- GUI development  
- Data parsing / cleaning  
- Signal visualization  
- Experiment automation  

### Research Workflow Skills
- Experiment design  
- Interpretation of real channel behaviors  
- Presenting wireless concepts visually  

### Systems Thinking
- Bridging hardware measurements → interpretable information  
- Making complex wireless behavior intuitive  

---

## 7. Narration / Reflection

This project was my first experience in turning **raw wireless behavior** into **visual insight**.

I realized:

- Real channels don’t behave like textbook channels  
- Logs are meaningless without visualization  
- Timing mismatches and asymmetric links dominate multi-hop performance  
- Visualization accelerates research understanding dramatically  

The project strengthened my skills in combining **engineering rigor**, **experimental thinking**, and 
**visual communication**, which later translated directly into how I approach debugging and system
analysis in DSP and audio engineering.

---
