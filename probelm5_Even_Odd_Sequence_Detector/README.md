# DFX-Based Even/Odd Sequence Classifier

## CAPTURE THE BITSTREAM Hackathon — Problem 5

This directory contains the available RTL implementation for **Problem 5: Even/Odd Sequence Classifier** from the **CAPTURE THE BITSTREAM Hackathon**.

The objective of this problem is to classify a finite-length discrete-time sequence according to its symmetry:

- **Even**
- **Odd**
- **Both even and odd**
- **Neither even nor odd**

The design uses FPGA Block RAM (BRAM) to store the input sequence and hardware logic to compare samples located symmetrically about the sequence boundaries.

The complete project was developed as a **Dynamic Function eXchange (DFX)** design. The DFX implementation flow was completed as part of the team project; however, this repository currently contains the available RTL source files for the classifier, BRAM, and FPGA top-level integration.

---

## Problem Statement

For a finite-length discrete-time sequence `x[n]`, the symmetry conditions are:

### Even Sequence

A sequence is even when:

```text
x[n] = x[N-1-n]
```

for all valid sample indices.

### Odd Sequence

A sequence is odd when:

```text
x[n] = -x[N-1-n]
```

for all valid sample indices.

Equivalently:

```text
x[n] - x[N-1-n] = 0     -> Even condition
x[n] + x[N-1-n] = 0     -> Odd condition
```

Only half of the sequence needs to be examined because every comparison simultaneously checks two mirrored samples.

For an 8-sample sequence, the comparisons are:

```text
x[0] <-> x[7]
x[1] <-> x[6]
x[2] <-> x[5]
x[3] <-> x[4]
```

---

## Design Architecture

The available RTL implementation consists of three main modules:

```text
                  +----------------------+
                  |     top_even_odd     |
                  |                      |
      Clock ----->|                      |
      Reset ----->|                      |
      Start ----->|                      |
                  |                      |
                  +----------+-----------+
                             |
                 +-----------+-----------+
                 |                       |
                 v                       v
      +--------------------+    +----------------------+
      |   bram_dualport    |    | even_odd_classifier  |
      |                    |    |                      |
      | Sequence Storage   |<-->| Symmetry Comparison  |
      | Dual Read Ports    |    | FSM + Classification |
      +--------------------+    +----------+-----------+
                                           |
                                           v
                                      LED Status
```

The BRAM stores the discrete-time sequence while the classifier generates two addresses corresponding to mirrored sequence positions.

The returned samples are tested for even and odd symmetry.

---

## Repository Structure

```text
problem5/
│
├── rtl/
│   ├── top_even_odd.v
│   ├── even_odd_classifier.v
│   └── bram_dualport.v
│
└── README.md
```

---

# RTL Modules

## 1. `top_even_odd.v`

`top_even_odd.v` is the top-level FPGA module.

It connects:

- FPGA clock
- Push-button reset
- Push-button start input
- Dual-port BRAM
- Even/Odd classifier
- LED status outputs

The top-level module converts the push-button input into a single-cycle start pulse before passing it to the classifier.

Conceptually:

```text
btnU
 |
 v
Edge Detector
 |
 v
Start Pulse
 |
 v
Even/Odd Classifier
```

The classifier then accesses the sequence stored in BRAM and performs the required symmetry checks.

---

## Push-Button Control

The implementation uses push buttons for classifier control.

```text
btnC -> Reset
btnU -> Start classification
```

A rising-edge detector is used on the start button so that holding the button does not repeatedly restart the classifier.

The generated pulse behaves conceptually as:

```text
start_pulse = btnU & ~btnU_d
```

where `btnU_d` stores the previous button state.

---

# 2. `bram_dualport.v`

The `bram_dualport` module implements the sequence memory.

Two independent read addresses are provided:

```text
addr_a
addr_b
```

with corresponding outputs:

```text
data_a
data_b
```

This allows two mirrored sequence samples to be fetched during the same comparison operation.

For example:

```text
addr_a = 0
addr_b = 7
```

retrieves:

```text
x[0]
x[7]
```

The next comparison retrieves:

```text
x[1]
x[6]
```

and so on.

---

## Example Sequence

The available BRAM RTL initializes the following 8-sample sequence:

```text
1, 2, 3, 4, 4, 3, 2, 1
```

This sequence satisfies:

```text
x[n] = x[N-1-n]
```

and therefore represents an **even sequence**.

Its mirrored samples are:

```text
x[0] = 1     x[7] = 1
x[1] = 2     x[6] = 2
x[2] = 3     x[5] = 3
x[3] = 4     x[4] = 4
```

Hence:

```text
x[n] - x[N-1-n] = 0
```

for every comparison.

---

# 3. `even_odd_classifier.v`

The `even_odd_classifier` module performs the actual sequence classification.

The module simultaneously tracks two conditions:

```text
even_flag
odd_flag
```

At the beginning of classification:

```text
even_flag = 1
odd_flag  = 1
```

Each mirrored sample pair is then tested.

---

## Even Test

For samples:

```text
x_left  = x[i]
x_right = x[N-1-i]
```

the even condition is:

```text
x_left - x_right = 0
```

If:

```text
x_left - x_right != 0
```

then:

```text
even_flag = 0
```

Once cleared, the flag remains cleared for the rest of the classification.

---

## Odd Test

The odd condition is:

```text
x_left + x_right = 0
```

If:

```text
x_left + x_right != 0
```

then:

```text
odd_flag = 0
```

Again, once the condition fails, the flag remains cleared.

---

# Parallel Symmetry Evaluation

The implementation evaluates both conditions during the same sequence traversal.

For each mirrored pair:

```text
                    x[i]
                     |
                     +----------------+
                     |                |
                     v                v
               +-----------+    +-----------+
x[N-1-i] ----->| SUBTRACT  |    |    ADD    |<----- x[N-1-i]
               +-----------+    +-----------+
                     |                |
                     v                v
                  == 0 ?           == 0 ?
                     |                |
                     v                v
                even_flag        odd_flag
```

Therefore, a separate traversal of the sequence is not required for each symmetry test in the available RTL implementation.

---

# BRAM Read Latency

The BRAM implementation uses synchronous reads.

Therefore, the classifier cannot generate an address and immediately evaluate the returned sample during the same clock cycle.

The FSM accounts for this memory latency by including a wait stage between address generation and comparison.

Conceptually:

```text
Set BRAM addresses
       |
       v
      WAIT
       |
       v
BRAM data available
       |
       v
Compare samples
```

This ensures that the classifier evaluates valid BRAM output data.

---

# Classifier FSM

The classification operation is controlled by a finite-state machine.

The general processing sequence is:

```text
       +------+
       | IDLE |
       +--+---+
          |
        start
          |
          v
     +---------+
     | Address |
     | Setup   |
     +----+----+
          |
          v
       +------+
       | WAIT |
       +--+---+
          |
          v
     +---------+
     | CHECK   |
     +----+----+
          |
     more pairs?
       /     \
     yes      no
      |        |
      +--------+-----> DONE
```

The classifier continues until all required mirrored pairs have been evaluated.

For a sequence length of:

```text
N = 8
```

only:

```text
N / 2 = 4
```

comparisons are required.

---

# Classification Results

At the end of the sequence traversal, the combination of `even_flag` and `odd_flag` determines the classification.

| `even_flag` | `odd_flag` | Classification |
|---:|---:|---|
| 1 | 0 | Even |
| 0 | 1 | Odd |
| 1 | 1 | Both Even and Odd |
| 0 | 0 | Neither |

The **both** condition can occur for the all-zero sequence because:

```text
0 = 0
```

and:

```text
0 = -0
```

are simultaneously true.

---

# LED Status Indication

The classification result is mapped to four LED status outputs.

```text
led_status[0] -> Even only
led_status[1] -> Odd only
led_status[2] -> Both even and odd
led_status[3] -> Neither
```

Therefore:

```text
Even:
0001

Odd:
0010

Both:
0100

Neither:
1000
```

This provides a direct visual indication of the classification result on the FPGA board.

---

# Example Classification

For the BRAM contents:

```text
x = {1, 2, 3, 4, 4, 3, 2, 1}
```

the classifier evaluates:

```text
1 - 1 = 0
2 - 2 = 0
3 - 3 = 0
4 - 4 = 0
```

so:

```text
even_flag = 1
```

For the odd condition:

```text
1 + 1 != 0
2 + 2 != 0
3 + 3 != 0
4 + 4 != 0
```

therefore:

```text
odd_flag = 0
```

Final classification:

```text
EVEN
```

and the corresponding status output is:

```text
led_status = 4'b0001
```

---

# Dynamic Function eXchange (DFX)

The complete team implementation of Problem 5 was developed using **Dynamic Function eXchange (DFX)**.

The intended DFX architecture separates the symmetry-checking functionality into reconfigurable functionality so that the FPGA can change the active processing function without requiring the entire device to be reconfigured.

Conceptually:

```text
                  Static FPGA Logic
                        |
                        v
              +-------------------+
              | Reconfigurable    |
              | Partition (RP)    |
              |                   |
              |   RM1 / RM2       |
              +-------------------+
                        |
                        v
                 Classification
```

The problem defines the reconfigurable functions as:

```text
RM1 -> Even Checker
RM2 -> Odd Checker
```

The DFX flow, including creation and implementation of the reconfigurable configurations, was completed as part of the team project.

---

## Repository Scope for DFX

The current repository snapshot contains the available RTL files:

```text
top_even_odd.v
even_odd_classifier.v
bram_dualport.v
```

The complete Vivado DFX project artifacts, including the separate RM implementation files, implementation checkpoints, generated bitstreams, and other Vivado-generated project files, are **not included in this directory**.

Therefore, the RTL provided here documents the underlying sequence-storage and symmetry-classification functionality used in the project, while the complete DFX implementation flow was performed separately during project development.

---

# Hardware Processing Flow

The overall RTL processing flow is:

```text
              START
                |
                v
       Initialize Flags
       even = 1
       odd  = 1
                |
                v
       Generate Addresses
       i and N-1-i
                |
                v
          Dual-Port BRAM
                |
          +-----+-----+
          |           |
          v           v
        x[i]      x[N-1-i]
          |           |
          +-----+-----+
                |
                v
       +----------------+
       | Symmetry Tests |
       +----------------+
          |          |
          v          v
       SUB == 0?   ADD == 0?
          |          |
          v          v
       EVEN FLAG   ODD FLAG
          \          /
           \        /
            v      v
          Next Pair
              |
              v
       All pairs checked?
          /       \
        No         Yes
        |           |
        +-----------+
                    |
                    v
             Classification
                    |
                    v
                   LEDs
```

---

# Key Design Features

The available implementation demonstrates:

- Finite-length sequence symmetry classification
- Even sequence detection
- Odd sequence detection
- Detection of both-even-and-odd sequences
- Detection of sequences with neither symmetry
- Dual-port BRAM-based sequence storage
- Simultaneous access to mirrored sequence samples
- FSM-based hardware control
- Synchronous BRAM latency handling
- Parallel even/odd condition evaluation
- FPGA push-button control
- LED-based result indication
- Parameterized sequence length
- Hardware-oriented implementation of discrete-time signal symmetry concepts
- Integration with a team DFX implementation flow

---

# Files Included

### `rtl/top_even_odd.v`

Top-level FPGA integration containing:

- push-button control
- start-pulse generation
- BRAM instantiation
- classifier instantiation
- LED result mapping

### `rtl/even_odd_classifier.v`

FSM-based symmetry classifier implementing:

```text
x[n] - x[N-1-n]
```

and:

```text
x[n] + x[N-1-n]
```

tests.

### `rtl/bram_dualport.v`

Dual-port synchronous memory used to store and retrieve mirrored samples of the finite-length sequence.

---

# Implementation Status

The available RTL implements the core sequence-classification datapath and control logic.

As part of the complete team project:

- RTL sequence storage was implemented
- Even/odd classification logic was implemented
- FPGA-level control and status indication were implemented
- The Dynamic Function eXchange flow was completed

The repository currently preserves the available RTL source code rather than the complete generated Vivado DFX project.

---

# Tools

The project was developed using:

- **AMD Vivado**
- **Verilog HDL**
- **SystemVerilog/RTL design concepts**
- **FPGA Block RAM**
- **Dynamic Function eXchange (DFX)**

---

# Problem 5 Summary

The implementation demonstrates how the mathematical definitions of even and odd discrete-time sequences can be translated into FPGA hardware.

Instead of checking every sequence element independently, the architecture exploits symmetry by reading mirrored samples:

```text
x[i]
x[N-1-i]
```

from a dual-port BRAM.

The hardware evaluates:

```text
x[i] - x[N-1-i]
```

for even symmetry and:

```text
x[i] + x[N-1-i]
```

for odd symmetry.

An FSM handles BRAM latency and iterates through the required sample pairs, after which the classification is displayed using FPGA LEDs.

The project was additionally integrated into a Dynamic Function eXchange workflow as part of the complete team implementation.

---

## CAPTURE THE BITSTREAM Hackathon

**Problem 5 — Even/Odd Sequence Classifier**

FPGA RTL implementation with BRAM-based sequence storage, hardware symmetry detection, LED classification output, and team-level Dynamic Function eXchange integration.