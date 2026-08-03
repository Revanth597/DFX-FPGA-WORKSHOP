# Reconfigurable Signal Generator using Dynamic Function eXchange (DFX)

## CAPTURE THE BITSTREAM Hackathon – Problem 4

This repository contains my implementation of **Problem 4: Reconfigurable Signal Generator** from the **CAPTURE THE BITSTREAM Hackathon**.

The objective of the problem is to demonstrate **Dynamic Function eXchange (DFX)** by implementing multiple waveform generators as Reconfigurable Modules (RMs) that share a common Reconfigurable Partition (RP).

---

## Problem Statement

**Difficulty:** 4/10

**Objective:** Generate different waveform types through Dynamic Function eXchange (DFX).

The problem specifies the following Reconfigurable Modules:

- **RM1 – Square Wave Generator**
- **RM2 – Sawtooth/Ramp Generator**
- **RM3 – Impulse Train Generator**

The original problem statement proposes outputting waveform samples through UART to a Python plotting GUI, or using PWM to drive an LED.

For this implementation, the focus was on the **RTL design, DFX configuration, simulation, implementation, and bitstream generation**. The waveform output was also mapped to the onboard LEDs for FPGA observation.

---

## System Architecture

The design consists of a static top-level system and a single Reconfigurable Partition.

```text
                         STATIC DESIGN
                    +---------------------+
                    |       top.v         |
                    |                     |
        clk ------->|                     |
        rst ------->|                     |
                    |   +-------------+   |
                    |   |             |   |
                    |   | RP          |   |
                    |   | rp_wrapper  |   |
                    |   |             |   |
                    |   | Active RM   |   |
                    |   +------+------+\  |
                    |          |          |
                    +----------|----------+
                               |
                         wave_out[7:0]
                               |
                               v
                         Basys 3 LEDs
```

The instance `RP` defines the **Reconfigurable Partition**.

Only the logic inside this partition changes between DFX configurations. The surrounding top-level logic remains static.

---

## Reconfigurable Modules

Three waveform generators are implemented for the same Reconfigurable Partition.

### 1. Square Wave Generator

`rtl/square_wave.v`

Generates a periodic square-wave output.

```text
HIGH  ────────┐        ┌────────
              │        │
LOW           └────────┘
```

---

### 2. Sawtooth / Ramp Generator

`rtl/sawtooth_wave.v`

Generates an incrementing digital ramp represented by an 8-bit output.

```text
255 |        /|        /|
    |       / |       / |
    |      /  |      /  |
    |     /   |     /   |
  0 |____/    |____/    |
```

The 8-bit value can be observed through the Basys 3 LEDs.

---

### 3. Impulse Train Generator

`rtl/impulse_wave.v`

Generates periodic impulses separated by a defined number of clock cycles.

```text
      |           |           |
      |           |           |
______|___________|___________|______
```

---

## DFX Architecture

All Reconfigurable Modules use a compatible interface so that they can occupy the same physical Reconfigurable Partition.

```text
                    Reconfigurable Partition
                         RP / rp_wrapper
                               |
             +-----------------+-----------------+
             |                 |                 |
             v                 v                 v
       +-------------+   +-------------+   +-------------+
       | Square Wave |   |  Sawtooth   |   |   Impulse   |
       |     RM      |   |     RM      |   |     RM      |
       +-------------+   +-------------+   +-------------+
```

Only **one RM is active in the Reconfigurable Partition for a given DFX configuration**.

The static portion of the FPGA design remains unchanged.

---

## Project Structure

```text
probelm4_Signal_Generator/
|
├── README.md
|
├── rtl/
│   ├── top.v
│   ├── rp_wrapper.v
│   ├── square_wave.v
│   ├── sawtooth_wave.v
│   └── impulse_wave.v
|
└── constraints/
    └── dfx_constraints.xdc
```

### RTL Files

| File | Description |
|---|---|
| `top.v` | Static top-level module |
| `rp_wrapper.v` | Wrapper defining the Reconfigurable Partition |
| `square_wave.v` | Square-wave Reconfigurable Module |
| `sawtooth_wave.v` | Sawtooth/ramp Reconfigurable Module |
| `impulse_wave.v` | Impulse-train Reconfigurable Module |

---

## FPGA Platform

The implementation targets the **Digilent Basys 3** FPGA development board.

| Parameter | Value |
|---|---|
| Board | Digilent Basys 3 |
| FPGA Family | AMD/Xilinx 7-Series |
| FPGA | Artix-7 |
| Clock | 100 MHz |
| HDL | Verilog |
| Design Tool | AMD Vivado |
| Reconfiguration Method | Dynamic Function eXchange (DFX) |

---

## FPGA I/O

The design uses the Basys 3 onboard 100 MHz clock, center push button, and eight LEDs.

| Design Signal | Board Resource | FPGA Pin |
|---|---|---|
| `clk` | 100 MHz Clock | W5 |
| `rst` | BTNC | U18 |
| `wave_out[0]` | LED0 | U16 |
| `wave_out[1]` | LED1 | E19 |
| `wave_out[2]` | LED2 | U19 |
| `wave_out[3]` | LED3 | V19 |
| `wave_out[4]` | LED4 | W18 |
| `wave_out[5]` | LED5 | U15 |
| `wave_out[6]` | LED6 | U14 |
| `wave_out[7]` | LED7 | V14 |

---

## DFX Physical Region

The Reconfigurable Partition is assigned to a dedicated physical region using a Vivado Pblock.

```tcl
create_pblock pblock_RP

add_cells_to_pblock [get_pblocks pblock_RP] \
    [get_cells -quiet [list RP]]

resize_pblock [get_pblocks pblock_RP] -add {
    SLICE_X4Y110:SLICE_X29Y144
    DSP48_X0Y44:DSP48_X0Y57
    RAMB18_X0Y44:RAMB18_X0Y57
    RAMB36_X0Y22:RAMB36_X0Y28
}
```

The same physical FPGA region is reused by the different Reconfigurable Modules.

---

## DFX Configurations

The design uses separate DFX configurations corresponding to the waveform generator loaded into the RP.

```text
Configuration 1
└── RP
    └── Square Wave Generator

Configuration 2
└── RP
    └── Sawtooth Wave Generator

Configuration 3
└── RP
    └── Impulse Train Generator
```

The static design remains common across all configurations.

---

## Design Flow

The project was implemented using the Vivado DFX flow:

```text
Verilog RTL
     |
     v
Create Static Design
     |
     v
Define Reconfigurable Partition
     |
     v
Add Reconfigurable Modules
     |
     v
Create DFX Configurations
     |
     v
RTL / Behavioral Simulation
     |
     v
Synthesis
     |
     v
Define RP Pblock
     |
     v
Implementation
     |
     v
Generate Bitstreams
```

---

## Simulation

Behavioral simulation was used to verify the waveform-generator modules before implementation.

The simulation testbench provides a **100 MHz clock** and reset and allows the output behavior of the Square, Sawtooth, and Impulse generators to be inspected in the Vivado waveform viewer.

For the sawtooth generator, the output should be viewed as an **unsigned multi-bit value** to clearly observe the increasing ramp.

---

## FPGA Output

The waveform generator output is connected to:

```text
wave_out[7:0]
```

which maps to the eight onboard Basys 3 LEDs.

This provides a simple hardware indication of the currently generated digital waveform.

The Square Wave configuration produces a clearly visible periodic LED state change. For multi-bit waveform generators such as the sawtooth generator, the LEDs represent the binary value of the generated sample.

---

## Hackathon Scope

The original challenge also proposes transmitting waveform samples through **UART to a Python plotting GUI**, or alternatively using **PWM to an LED**.

The implementation in this repository focuses on:

- Verilog implementation of all three waveform generators
- Common DFX-compatible interface
- Reconfigurable Partition creation
- Multiple Reconfigurable Modules
- DFX configurations
- Behavioral simulation
- Physical Pblock assignment
- FPGA implementation
- Bitstream generation
- LED-based FPGA observation

UART/Python waveform plotting is **not included in the current implementation**.

---

## Key Concepts Demonstrated

This project demonstrates:

- Dynamic Function eXchange (DFX)
- Reconfigurable Partitions (RP)
- Reconfigurable Modules (RM)
- Static and reconfigurable FPGA regions
- Pblock-based floorplanning
- Multiple hardware functions sharing the same FPGA region
- Behavioral simulation of digital waveform generators
- FPGA bitstream generation using Vivado

---

## Hackathon Problem Statement

This project was developed as a solution to the **CAPTURE THE BITSTREAM Hackathon**.

The original hackathon problem statement is included at the root of the repository:

```text
CAPTURE_THE_BITSTREAM_Hackathon_Problem_Statements.pdf
```

Problem 4 defines the Reconfigurable Signal Generator challenge implemented in this directory.

---

## Disclaimer

This repository contains a participant implementation of the hackathon problem and is intended for educational and demonstration purposes.

The original problem statement belongs to its respective organizers/authors.