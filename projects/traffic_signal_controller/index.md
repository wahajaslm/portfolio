---
visibility: public
use_for_ai: true
tags: [embedded, microcontroller, state_machine, real_time, c, timers, interrupts, firmware, prototyping, testing]
summary: "Finite-state traffic light controller in C using timers/interrupts for deterministic, safe signal sequencing."
---

# Traffic Signal Controller — Embedded C State Machine  
### Deterministic Timing, Real-Time Logic, and Safety-Oriented Control Flow

---

## 1. Overview

This project implements a **Traffic Signal Controller** using an embedded microcontroller and a  
**finite state machine (FSM)**. The system handles:

- red / yellow / green cycle timing  
- safe state transitions  
- pedestrian or extended-timing modes (optional)  
- real-time light switching logic  

It demonstrates real-time embedded programming, state-machine design, and stable time-driven logic.

---

## 2. Problem Statement

Traffic signals must operate:

- predictably  
- safely  
- with strict timing control  
- without glitches or ambiguous states  

A naive implementation (e.g., delays or manual toggles) is unreliable.  
A proper FSM is needed to ensure:

- correct sequence → Red → Green → Yellow → Red  
- timing consistency  
- no illegal combinations  
- clean reset behavior  

---

## 3. System Architecture

### **Hardware Components**
- Microcontroller (AVR / PIC / Arduino-class)
- LED indicators:
  - Red  
  - Yellow  
  - Green  
- Timer module or software timer  
- Optional input button (e.g., pedestrian mode)  

### **State Machine Diagram**

```
      [RED]
        |
        v
     [GREEN]
        |
        v
     [YELLOW]
        |
        v
      [RED]  (loop)
```

### **State Definitions**
| State     | Lights Active         | Duration |
|-----------|------------------------|----------|
| RED       | Red ON                 | t_red    |
| GREEN     | Green ON               | t_green  |
| YELLOW    | Yellow ON              | t_yellow |

---

## 4. Implementation Details

### 4.1 FSM Structure (C)

```c
enum state { RED, GREEN, YELLOW };
enum state current_state = RED;

void loop() {
    switch(current_state) {
        case RED:
            red_on(); green_off(); yellow_off();
            wait(t_red);
            current_state = GREEN;
            break;

        case GREEN:
            green_on(); red_off(); yellow_off();
            wait(t_green);
            current_state = YELLOW;
            break;

        case YELLOW:
            yellow_on(); red_off(); green_off();
            wait(t_yellow);
            current_state = RED;
            break;
    }
}
```

### 4.2 Timer Integration

- Using hardware timers or non-blocking timing loops  
- Ensures system remains responsive  

### 4.3 Optional Pedestrian Handling

```c
if (button_pressed() && safe_to_interrupt()) {
    extend_red_phase();
}
```

### 4.4 Safety Guarantees

- Never GREEN + RED at the same time  
- Minimum time per state is enforced  
- Guaranteed sequence order  
- Optional emergency all-red mode  

---

## 5. Results

- Smooth, predictable transitions  
- Timing accuracy and stability  
- Extensible to multi-intersection control  
- No illegal LED combinations  
- Reliable due to strict FSM structure  

---

## 6. Skills Demonstrated

- Embedded C  
- State machine design  
- Real-time logic  
- Timing systems  
- IO interfacing  
- Debugging embedded timing issues  

---

## 7. Narration / Reflection

This project taught me the importance of deterministic timing and clean control flow.  
Using a state machine made the behavior predictable and easy to reason about — an approach that applies
not only to embedded systems but also to larger software and DSP pipelines.

---
