# FPGA & Dynamic Function eXchange Workshop — 2026

This repository documents our FPGA and **Dynamic Function eXchange (DFX)** implementations developed during the **FPGA & DPR Workshop** organized by **CHIPS, PES University**.

The three-day workshop was conducted at **PES University, Electronic City Campus** from **30 July to 1 August 2026**, covering FPGA architecture, the AMD Vivado design flow, Dynamic Function eXchange, partial reconfiguration, and hands-on FPGA implementation.

On **Day 3**, participants worked in teams on a set of FPGA/DFX design challenges as part of the **CAPTURE THE BITSTREAM** hands-on challenge.

Our team successfully completed **all the assigned problem statements and was the first team to solve them**, winning the Day 3 challenge.

---

# Team

### Repository Owner

**Revanth A H**

### Contributors

- **Parthavi N R**
- **Mithil Kumar**

The three of us worked as a team during the Day 3 FPGA & DFX challenge.

---

# Workshop

## FPGA & DPR Workshop

**Organized by:** CHIPS | PES University  
**Venue:** PES University, EC Campus  
**Dates:** 30 July, 31 July & 1 August 2026  
**Duration:** 3 Days

The workshop focused on taking participants from fundamental FPGA concepts to practical implementation of **Dynamic Partial Reconfiguration / Dynamic Function eXchange** using AMD Vivado.

---

## Day 1 — FPGA Basics & Architecture

Day 1 introduced the fundamental concepts required for FPGA development.

Topics included:

- Introduction to FPGAs
- History and evolution of FPGA technology
- FPGA architecture
- Configurable Logic Blocks (CLBs)
- Lookup Tables (LUTs)
- Flip-Flops
- Routing resources
- Block RAM
- DSP resources
- FPGA I/O
- Clocking
- Vivado design flow
- RTL design entry
- Synthesis
- Implementation
- Timing fundamentals
- Bitstream generation

---

## Day 2 — Dynamic Function eXchange

Day 2 introduced **Dynamic Function eXchange (DFX)**, also commonly associated with Dynamic Partial Reconfiguration.

Topics included:

- Need for FPGA reconfiguration
- Dynamic Partial Reconfiguration concepts
- Dynamic Function eXchange
- Static Region
- Reconfigurable Partition (RP)
- Reconfigurable Modules (RM)
- RP/RM interfaces
- DFX design flow in Vivado
- Partitioning
- Floorplanning
- Pblocks
- DFX constraints
- Partial bitstream generation
- Partial bitstream management

A central idea explored during the workshop was that a portion of the FPGA can be reconfigured while the remainder of the device continues to retain its implemented static functionality.

---

# Day 3 — CAPTURE THE BITSTREAM Challenge

The final day focused on complete hands-on FPGA and DFX implementation.

Participants were given FPGA design problems that required applying the concepts learned during the first two days.

The challenge involved:

- RTL design
- Functional verification
- Vivado synthesis
- FPGA implementation
- Reconfigurable Partitions
- Reconfigurable Modules
- DFX floorplanning
- Pblock creation
- DFX constraints
- Bitstream generation
- Partial bitstream generation
- Hardware testing
- Dynamic reconfiguration

Our team consisted of:

```text
Revanth A H
Parthavi N R
Mithil Kumar
```

We completed **all the challenge problem statements before the other participating teams and won the Day 3 challenge**.

This repository preserves and documents the RTL, verification files, constraints, DFX-related files, implementation results, and other project material that remained available from our work.

---

# Repository Structure

```text
DFX-FPGA-WORKSHOP/
│
├── problem1_matrix_computation_accelerator/
│   ├── rtl/
│   └── README.md
│
├── problem2_Signal_Processing_Engine/
│   ├── rtl/
│   ├── tb/
│   ├── constraints/
│   ├── images/
│   └── README.md
│
├── problem3_Scientific_Calculator/
│   ├── rtl/
│   ├── ip/
│   ├── tb/
│   ├── constraints/
│   ├── block_design/
│   ├── images/
│   └── README.md
│
├── problem4_Signal_Generator/
│   ├── rtl/
│   ├── constraints/
│   ├── images/
│   └── README.md
│
├── problem5/
│   ├── rtl/
│   └── README.md
│
├── CAPTURE_THE_BITSTREAM_Hackathon_Problem_Statements.pdf
│
└── README.md
```

> Some original Vivado project files, generated checkpoints, bitstreams, and implementation artifacts were not retained for every problem. The repository therefore contains the available project material for each design.

---

# Problem 1 — Matrix Computation Accelerator

The first problem implements an FPGA-based **Matrix Computation Accelerator**.

The available RTL contains modules for operations including:

- Matrix addition
- Matrix multiplication
- Matrix transpose
- UART communication
- Top-level matrix accelerator control

Available RTL includes:

```text
rm1_matrix_add.v
rm2_matrix_mult.sv
rm3_matrix_transpose.sv
top_matrix_accel.sv
uart_rx.sv
uart_tx.sv
```

The different matrix-processing functions were designed around the reconfigurable-computing concepts explored during the workshop.

For implementation details, see:

```text
problem1_matrix_computation_accelerator/README.md
```

---

# Problem 2 — Signal Processing Engine

Problem 2 implements a **reconfigurable signal-processing engine**.

The processing functions include:

```text
Moving Average
FIR Low-Pass Filter
Peak Detection
```

The repository contains the RTL implementations and behavioral verification for the three processing functions.

The design demonstrates how multiple signal-processing functions can share a common interface and be used as alternative functions within a DFX architecture.

Available modules include:

```text
moving_average.v
fir_lpf.v
peak_detection_engine.v
rp_wrapper.v
top.v
```

Behavioral simulation results are also documented for the individual processing engines.

The project additionally contains the physical **Pblock definition** used for the Reconfigurable Partition.

For complete details, see:

```text
problem2_Signal_Processing_Engine/README.md
```

---

# Problem 3 — Scientific Calculator

Problem 3 implements a **DFX-based Scientific Calculator**.

The design combines:

- Zynq-7000 Processing System
- AXI4-Lite communication
- Custom AXI peripheral
- Reconfigurable arithmetic functionality
- DFX Reconfigurable Partition

The calculator contains multiple computational functions including arithmetic, integer-logic, and decision-oriented operations.

The repository preserves the custom RTL, AXI peripheral RTL, block-design information, simulations, DFX constraints, and floorplanning results.

The design demonstrates integration between:

```text
Zynq PS
   |
AXI4-Lite
   |
Custom AXI Peripheral
   |
Reconfigurable Processing Logic
```

For complete architecture and implementation details, see:

```text
problem3_Scientific_Calculator/README.md
```

---

# Problem 4 — Signal Generator

Problem 4 implements a **DFX-based digital signal generator**.

The design provides multiple waveform-generation functions that can occupy a common reconfigurable region.

The implemented waveform generators include:

```text
Impulse Wave
Square Wave
Sawtooth Wave
```

Each generator follows a compatible interface, allowing the waveform-generation function to be changed as part of the DFX architecture.

The project demonstrates:

- Multiple Reconfigurable Modules
- Common RP interfaces
- Behavioral simulation
- FPGA implementation
- DFX floorplanning
- Pblock assignment
- Partial reconfiguration concepts
- FPGA LED observation

For complete details, see:

```text
problem4_Signal_Generator/README.md
```

---

# Problem 5 — Even/Odd Sequence Classifier

Problem 5 implements hardware for classifying a finite-length discrete-time sequence as:

```text
Even
Odd
Both Even and Odd
Neither
```

The classifier evaluates mirrored samples:

```text
x[n]
x[N-1-n]
```

and tests the mathematical conditions:

```text
x[n] - x[N-1-n] = 0
```

for even symmetry and:

```text
x[n] + x[N-1-n] = 0
```

for odd symmetry.

The available implementation includes:

- Dual-port BRAM sequence storage
- FSM-based classifier
- Even/odd symmetry evaluation
- FPGA top-level integration
- LED result indication

The complete DFX implementation was performed during the team challenge, while the repository currently preserves the available RTL implementation.

For complete details, see:

```text
problem5/README.md
```

---

# Dynamic Function eXchange

A major objective of the workshop was understanding and implementing **Dynamic Function eXchange**.

Traditional FPGA configuration programs the complete FPGA fabric using a full bitstream.

DFX allows a selected region to be reconfigured independently.

Conceptually:

```text
                 FPGA
+-------------------------------------+
|                                     |
|            STATIC REGION            |
|                                     |
|      +-----------------------+      |
|      |                       |      |
|      | Reconfigurable        |      |
|      | Partition (RP)        |      |
|      |                       |      |
|      |  RM1 / RM2 / RM3 ... |      |
|      |                       |      |
|      +-----------------------+      |
|                                     |
+-------------------------------------+
```

Different **Reconfigurable Modules (RMs)** can implement different functions while maintaining the same RP interface.

For example:

```text
                   RP
                    |
       +------------+------------+
       |            |            |
       v            v            v
      RM1          RM2          RM3

 Moving Avg      FIR LPF     Peak Detector
```

or:

```text
                   RP
                    |
       +------------+------------+
       |            |            |
       v            v            v
      RM1          RM2          RM3

   Impulse       Square      Sawtooth
```

This enables hardware functionality to be changed without replacing the entire FPGA configuration.

---

# DFX Development Flow

The workshop introduced and applied a DFX workflow based on:

```text
RTL Design
    |
    v
Functional Simulation
    |
    v
Synthesis
    |
    v
Define Reconfigurable Partition
    |
    v
Create Pblock
    |
    v
Floorplanning
    |
    v
Implement Static + RM Configuration
    |
    v
Generate Full Bitstream
    |
    v
Generate Partial Bitstreams
    |
    v
Program FPGA
    |
    v
Dynamic Reconfiguration
```

This repository documents several stages of this process across the different challenge problems.

---

# Tools & Technologies

The projects use concepts and tools including:

- AMD Vivado
- FPGA RTL Design
- Verilog
- SystemVerilog
- Dynamic Function eXchange (DFX)
- Dynamic Partial Reconfiguration (DPR)
- Reconfigurable Partitions
- Reconfigurable Modules
- Vivado Pblocks
- Behavioral Simulation
- Synthesis
- Implementation
- Floorplanning
- Block RAM
- DSP resources
- AXI4-Lite
- Zynq-7000
- Basys 3
- UART
- Partial Bitstreams

---

# Verification

Where the original verification files were available, they have been included with the corresponding problem.

The repository contains behavioral simulation material for designs such as:

```text
Scientific Calculator
Signal Processing Engine
```

These simulations were used to verify individual RTL functions before progressing further through the FPGA implementation flow.

Screenshots of relevant simulation and implementation results are included within the respective problem directories where available.

---

# Challenge Result

During the **Day 3 CAPTURE THE BITSTREAM challenge**, our team:

**Revanth A H · Parthavi N R · Mithil Kumar**

worked together on the FPGA and DFX problem statements.

Our team successfully completed **all the assigned challenge problems first**, making us the **winning team of the Day 3 challenge**.

The repository was created to preserve and document the designs developed during the workshop and the technical work behind the solutions.

---

# Workshop Takeaways

The three-day workshop provided practical experience moving from fundamental FPGA concepts to dynamically reconfigurable hardware.

The work covered the complete progression:

```text
Digital Logic
      ↓
RTL Design
      ↓
Simulation
      ↓
Synthesis
      ↓
Implementation
      ↓
FPGA Architecture
      ↓
Reconfigurable Partitions
      ↓
Reconfigurable Modules
      ↓
DFX Floorplanning
      ↓
Partial Bitstreams
      ↓
Dynamic FPGA Reconfiguration
```

Rather than treating DFX only as a theoretical concept, the final challenge required applying these concepts to actual hardware-oriented designs.

---

# Acknowledgement

We would like to acknowledge **CHIPS, PES University** and the organizers and mentors of the **FPGA & DPR Workshop** for conducting the three-day hands-on program and providing the opportunity to work with FPGA design and Dynamic Function eXchange.

The workshop concluded with the Day 3 challenge, allowing us to apply the concepts learned during the sessions to practical FPGA design problems.

---

# Authors & Contributors

### Revanth A H
Repository creator and Day 3 team member

### Parthavi N R
Day 3 team member and contributor

### Mithil Kumar
Day 3 team member and contributor

---

## Workshop

**FPGA & DPR Workshop**  
**30 July – 1 August 2026**  
**PES University, Electronic City Campus**

### Day 3 — CAPTURE THE BITSTREAM

🏆 **Winning Team — First to complete all assigned challenge problems**

**Revanth A H · Parthavi N R · Mithil Kumar**

---

> **Design Today. Reconfigure Tomorrow.**