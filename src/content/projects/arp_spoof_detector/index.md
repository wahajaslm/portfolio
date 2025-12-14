---
visibility: public
use_for_ai: true
tags: [network_security, arp_spoofing, intrusion_detection, packet_sniffing, python, scapy, wireshark, bash, networking, automation]
summary: "Python/Scapy ARP spoof detector with packet inspection, MAC/IP verification, and Wireshark-friendly logging."
title: "ARP Spoof Detector"
---

# ARP Spoof Detector — Python-Based Network Security Tool  

## Overview

The **ARP Spoof Detector** is a Python-based defensive security tool that monitors a local network for
**ARP poisoning** attacks. ARP spoofing is a common technique used to:

- intercept traffic (Man-in-the-Middle attacks)  
- disrupt network connectivity  
- impersonate gateway or device IPs  

This tool continuously scans ARP packets, identifies suspicious MAC/IP mismatches, and alerts the user
in real time.

It demonstrates:

- network traffic analysis  
- ARP protocol understanding  
- attack detection logic  
- practical cybersecurity engineering  

## Problem Statement

In ARP spoofing:

- an attacker sends false ARP replies  
- associates their MAC with a victim’s IP address  
- reroutes or intercepts traffic  

Most devices never verify ARP messages, making the LAN vulnerable.

The goal of this project:

- detect ARP spoof events quickly  
- verify MAC/IP relationships  
- warn the user immediately  
- run efficiently on typical local networks  

## System Architecture

```
Network Traffic → Packet Sniffer → ARP Analyzer → MAC Verification → Alert System
```

### Components

1. **Packet Sniffer**  
   - Uses `scapy` in Python  
   - Listens for ARP “who-has” and “is-at” packets  

2. **MAC Verification Engine**  
   - Maintains a trusted MAC–IP mapping table  
   - Detects changes or inconsistencies  

3. **Spoof Detection Logic**
   - Identifies if two different MAC addresses claim the same IP  
   - Flags if gateway IP is claimed by a non-gateway MAC  

4. **Alert System**
   - Console warnings  
   - Optional logging  
   - Optional email/SMS alerts (extensible)

## Implementation Details

### Packet Sniffing

Using Scapy:

```python
from scapy.all import sniff, ARP

def sniff_packets():
    sniff(store=False, prn=analyze_packet, filter="arp")
```

### ARP Analysis Logic

```python
def analyze_packet(pkt):
    if pkt.haslayer(ARP) and pkt[ARP].op == 2:  # ARP Reply
        ip = pkt[ARP].psrc
        mac = pkt[ARP].hwsrc

        if ip in ip_mac_table and ip_mac_table[ip] != mac:
            alert(ip, ip_mac_table[ip], mac)
        else:
            ip_mac_table[ip] = mac
```

### Spoof Detection Conditions

- **Condition A:** Same IP seen with two different MACs  
- **Condition B:** Gateway IP claimed by an unknown MAC  
- **Condition C:** MAC address appears on sudden multiple IPs  

### Alert Function

```python
def alert(ip, original_mac, spoofed_mac):
    print(f"[!] Possible ARP Spoof Detected:")
    print(f"    IP Address: {ip}")
    print(f"    Original MAC: {original_mac}")
    print(f"    Detected MAC: {spoofed_mac}")
```

### Performance Considerations

- Real-time detection with low CPU usage  
- Works on Wi-Fi and Ethernet  
- No need for packet storage → memory efficient  

## Results

- Successfully detects ARP spoof attempts in real networks  
- Works immediately on common networks without special setup  
- Detects gateway spoofing (most dangerous case)  
- Minimal system resource usage  
- Easy to extend into a full IDS module  

## Skills Demonstrated

- Python networking  
- Packet sniffing using Scapy  
- Understanding ARP protocol internals  
- Intrusion detection logic  
- Pattern recognition for MAC/IP inconsistencies  
- Practical cybersecurity tooling  

## Narration / Reflection

Building this tool gave me hands-on insight into how simple but dangerous ARP spoofing is on typical
networks. It reinforced:

- the importance of validating assumptions in protocols  
- how fragile local network trust systems can be  
- how lightweight detection can significantly improve security  

This project strengthened my ability to think like both an attacker **and** a defender — a skill that later
helped in debugging complex system interactions across networking, DSP, and embedded domains.

---
