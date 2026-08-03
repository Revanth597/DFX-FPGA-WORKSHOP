# Reconfigurable 5×5 Matrix Computation Accelerator

## CAPTURE THE BITSTREAM Hackathon — Problem 1

This directory contains the available RTL implementation for **Problem 1: Reconfigurable 5×5 Matrix Computation Accelerator** from the **CAPTURE THE BITSTREAM Hackathon**.

The objective of the problem is to implement a hardware accelerator capable of performing multiple operations on **5×5 integer matrices**, with the computational function intended to be changed using **Dynamic Function eXchange (DFX)**.

The three matrix-processing functions defined by the challenge are:

- **RM1 — Matrix Addition**
- **RM2 — Matrix Multiplication**
- **RM3 — Matrix Transpose**

The design also includes UART receive and transmit modules for transferring matrix data between a host computer and the FPGA.

---

## Problem Statement

The accelerator is designed around three matrix operations:

### RM1 — Matrix Addition

For two 5×5 matrices `A` and `B`, matrix addition computes:

```text
C[i][j] = A[i][j] + B[i][j]
```

for:

```text
i = 0 ... 4
j = 0 ... 4
```

---

### RM2 — Matrix Multiplication

Matrix multiplication computes each output element using a multiply-accumulate operation:

```text
             4
C[i][j] =   Σ   A[i][k] × B[k][j]
            k=0
```

Each output element therefore requires five multiplication-and-accumulation operations.

---

### RM3 — Matrix Transpose

Matrix transpose interchanges the rows and columns of the input matrix:

```text
C[i][j] = A[j][i]
```

For example:

```text
Input A                  Transpose C

a00 a01 a02 a03 a04      a00 a10 a20 a30 a40
a10 a11 a12 a13 a14      a01 a11 a21 a31 a41
a20 a21 a22 a23 a24  ->  a02 a12 a22 a32 a42
a30 a31 a32 a33 a34      a03 a13 a23 a33 a43
a40 a41 a42 a43 a44      a04 a14 a24 a34 a44
```

---

# RTL Architecture

The available implementation contains the three matrix-processing modules together with UART communication and top-level control logic.

```text
                         Host Computer
                              │
                              │ UART
                              ▼
                       ┌─────────────┐
                       │   UART RX   │
                       │ uart_rx.sv  │
                       └──────┬──────┘
                              │
                              ▼
                  ┌───────────────────────┐
                  │   top_matrix_accel    │
                  │                       │
                  │ Matrix Data Storage   │
                  │ Operation Selection   │
                  │ Control / Sequencing  │
                  └───────────┬───────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
       ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
       │     RM1     │ │     RM2     │ │     RM3     │
       │             │ │             │ │             │
       │   Matrix    │ │   Matrix    │ │   Matrix    │
       │  Addition   │ │Multiplication│ │  Transpose  │
       └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
              │               │               │
              └───────────────┼───────────────┘
                              │
                              ▼
                       Result Matrix
                              │
                              ▼
                       ┌─────────────┐
                       │   UART TX   │
                       │ uart_tx.sv  │
                       └──────┬──────┘
                              │
                              │ UART
                              ▼
                         Host Computer
```

---

# Repository Structure

```text
problem1_matrix_computation_accelerator/
│
├── rtl/
│   ├── rm1_matrix_add.v
│   ├── rm2_matrix_mult.sv
│   ├── rm3_matrix_transpose.sv
│   ├── top_matrix_accel.sv
│   ├── uart_rx.sv
│   └── uart_tx.sv
│
└── README.md
```

---

# RTL Module Description

## `rm1_matrix_add.v`

Implements the **5×5 matrix addition engine**.

The module receives two matrices and performs element-wise addition:

```text
C = A + B
```

For example:

```text
A =                  B =

1  2  3  4  5        5  4  3  2  1
1  2  3  4  5        5  4  3  2  1
1  2  3  4  5   +    5  4  3  2  1
1  2  3  4  5        5  4  3  2  1
1  2  3  4  5        5  4  3  2  1

C =

6  6  6  6  6
6  6  6  6  6
6  6  6  6  6
6  6  6  6  6
6  6  6  6  6
```

The 25 elements of the matrices are processed to generate the corresponding 25-element result matrix.

---

## `rm2_matrix_mult.sv`

Implements the **5×5 matrix multiplication engine**.

Unlike element-wise addition, matrix multiplication calculates every output element using a dot product between one row of matrix `A` and one column of matrix `B`.

```text
C[row][col] =
    A[row][0] × B[0][col] +
    A[row][1] × B[1][col] +
    A[row][2] × B[2][col] +
    A[row][3] × B[3][col] +
    A[row][4] × B[4][col]
```

The RTL uses sequential control to step through the row, column, and multiply-accumulate operations required to construct the complete output matrix.

This makes matrix multiplication the most computationally intensive of the three matrix functions.

---

## `rm3_matrix_transpose.sv`

Implements the **5×5 matrix transpose engine**.

The transpose operation exchanges the row and column indices:

```text
Output[col][row] = Input[row][col]
```

For example:

```text
1   2   3   4   5
6   7   8   9  10
11 12  13  14  15
16 17  18  19  20
21 22  23  24  25
```

becomes:

```text
1   6  11  16  21
2   7  12  17  22
3   8  13  18  23
4   9  14  19  24
5  10  15  20  25
```

---

# Top-Level Matrix Accelerator

## `top_matrix_accel.sv`

`top_matrix_accel.sv` provides the top-level control logic for the available RTL implementation.

Its responsibilities include:

- Receiving bytes from the UART receiver
- Interpreting the requested matrix operation
- Collecting incoming matrix elements
- Storing the input matrix data
- Providing matrix data to the computation modules
- Initiating computation
- Selecting the appropriate result
- Sending result data through the UART transmitter

The top-level module therefore connects the communication subsystem with the three matrix-processing engines.

Conceptually:

```text
UART RX
   │
   ▼
Receive Operation
   │
   ▼
Receive Matrix Data
   │
   ▼
Store Matrices A/B
   │
   ▼
Start Matrix Operation
   │
   ├─────────────┬──────────────┐
   ▼             ▼              ▼
Addition    Multiplication   Transpose
   │             │              │
   └─────────────┴──────────────┘
                 │
                 ▼
            Result Matrix
                 │
                 ▼
              UART TX
```

---

# Operation Selection

The top-level communication protocol uses an operation/mode value to identify the required matrix function.

The RTL defines the following operation values:

| Mode | Operation |
|---|---|
| `0x01` | Matrix Addition |
| `0x02` | Matrix Multiplication |
| `0x03` | Matrix Transpose |

The selected mode determines which matrix-processing result is used by the top-level accelerator.

---

# UART Communication

Two UART modules are included in the available source code.

## `uart_rx.sv`

The UART receiver converts the serial UART input stream into parallel data bytes that can be consumed by the matrix accelerator.

```text
Serial RX
   │
   ▼
┌─────────────┐
│   UART RX   │
└──────┬──────┘
       │
       ▼
  Received Byte
       │
       ▼
Matrix Accelerator
```

---

## `uart_tx.sv`

The UART transmitter performs the reverse operation.

Result data generated by the accelerator is provided to the UART transmitter, which serializes the data for transmission back to the host.

```text
Matrix Accelerator
       │
       ▼
   Result Byte
       │
       ▼
┌─────────────┐
│   UART TX   │
└──────┬──────┘
       │
       ▼
   Serial TX
```

Together, `uart_rx.sv` and `uart_tx.sv` form the communication interface between the FPGA-side matrix accelerator and the external host.

---

# Matrix Data Organization

Each matrix contains:

```text
5 × 5 = 25 elements
```

Two input matrices therefore contain:

```text
Matrix A = 25 elements
Matrix B = 25 elements

Total = 50 input elements
```

The accelerator generates a 25-element output matrix.

Conceptually, the matrices can be represented internally as flattened arrays:

```text
Matrix A

A[0]   A[1]   A[2]   A[3]   A[4]
A[5]   A[6]   A[7]   A[8]   A[9]
A[10]  A[11]  A[12]  A[13]  A[14]
A[15]  A[16]  A[17]  A[18]  A[19]
A[20]  A[21]  A[22]  A[23]  A[24]
```

The same organization is used conceptually for Matrix B and the result Matrix C.

For a row `r` and column `c`, the flattened index is:

```text
index = r × 5 + c
```

---

# Intended DFX Organization

The original hackathon problem defines the three matrix functions as **Reconfigurable Modules (RMs)**.

The intended architecture is therefore:

```text
                  STATIC FPGA REGION
        ┌──────────────────────────────────┐
        │                                  │
UART RX │                                  │ UART TX
───────►│       Reconfigurable             ├───────►
        │       Partition (RP)             │
        │                                  │
        │      ┌────────────────────┐      │
        │      │                    │      │
        │      │   Active RM        │      │
        │      │                    │      │
        │      │  RM1: Addition     │      │
        │      │       OR           │      │
        │      │  RM2: Multiply     │      │
        │      │       OR           │      │
        │      │  RM3: Transpose    │      │
        │      │                    │      │
        │      └────────────────────┘      │
        │                                  │
        └──────────────────────────────────┘
```

Only one matrix-processing implementation is intended to occupy the Reconfigurable Partition for a particular DFX configuration.

The static communication and control infrastructure can remain present while the matrix-processing function is exchanged.

---

# Dynamic Function eXchange

Dynamic Function eXchange allows a selected region of an FPGA to be reconfigured independently of the remainder of the design.

For this problem, the matrix computation engine is intended to provide three possible configurations:

```text
Configuration 1
RP ← Matrix Addition

Configuration 2
RP ← Matrix Multiplication

Configuration 3
RP ← Matrix Transpose
```

This allows the same physical FPGA region to implement different matrix-processing hardware functions.

---

# Host-Side Communication

The original hackathon specification also calls for a host PC application communicating with the FPGA through UART.

The intended system-level flow is:

```text
          HOST PC
             │
             │ Matrix A
             │ Matrix B
             │ Operation
             ▼
           UART
             │
             ▼
     ┌─────────────────┐
     │      FPGA       │
     │                 │
     │ Matrix          │
     │ Accelerator     │
     │                 │
     └────────┬────────┘
              │
              │ Result Matrix
              ▼
            UART
              │
              ▼
          HOST PC
```

The hackathon specification proposes a Python GUI for displaying the input and output matrices.

---

# Repository Scope

This repository contains the **RTL source files currently available for this implementation**.

Included:

- Matrix Addition RTL
- Matrix Multiplication RTL
- Matrix Transpose RTL
- Matrix accelerator top-level RTL
- UART receiver RTL
- UART transmitter RTL

The following artifacts from the broader hackathon workflow are **not included in this directory**:

- Vivado DFX project files
- Reconfigurable Partition constraints
- Pblock/floorplanning constraints
- DFX implementation runs
- Full and partial bitstreams
- Testbench source files
- Simulation screenshots/results
- Python GUI source
- Host-side software

Therefore, this directory should be considered an **RTL source archive of the available Problem 1 implementation**, rather than a complete reproducible Vivado DFX project.

---

# Available Source Files

| File | Purpose |
|---|---|
| `rm1_matrix_add.v` | 5×5 matrix addition |
| `rm2_matrix_mult.sv` | 5×5 matrix multiplication |
| `rm3_matrix_transpose.sv` | 5×5 matrix transpose |
| `top_matrix_accel.sv` | Top-level matrix accelerator and operation control |
| `uart_rx.sv` | UART serial receiver |
| `uart_tx.sv` | UART serial transmitter |

---

# Design Flow

The overall intended processing sequence is:

```text
1. Host selects matrix operation
              │
              ▼
2. Matrix data transmitted through UART
              │
              ▼
3. UART RX reconstructs received bytes
              │
              ▼
4. top_matrix_accel stores input data
              │
              ▼
5. Selected matrix operation is executed
              │
              ▼
6. Result matrix is collected
              │
              ▼
7. Result bytes are passed to UART TX
              │
              ▼
8. Result transmitted back to host
```

---

# Key Concepts Demonstrated

The available RTL demonstrates several FPGA and digital-design concepts:

- Hardware matrix processing
- 5×5 matrix representation
- Element-wise arithmetic
- Multiply-accumulate computation
- Sequential control for matrix multiplication
- Matrix index transformation
- UART serial communication
- FPGA/host data transfer
- Modular RTL architecture
- Separation of computation and communication logic
- Hardware functions intended for use as DFX Reconfigurable Modules

---

# Hackathon Context

**CAPTURE THE BITSTREAM — Problem 1**

**Problem:** Reconfigurable 5×5 Matrix Computation Accelerator

**Difficulty:** 10/10

The challenge defines three reconfigurable matrix-processing functions:

```text
RM1 → Matrix Addition
RM2 → Matrix Multiplication
RM3 → Matrix Transpose
```

The complete challenge additionally calls for UART communication with a host PC and a Python GUI for displaying the input and output matrices.

---

# Note

Only the RTL source files that were available when this repository was assembled are included here.

Consequently, the repository documents the available matrix accelerator implementation without claiming that the original Vivado DFX project, implementation artifacts, partial bitstreams, verification environment, or Python GUI are reproduced here.

---

## CAPTURE THE BITSTREAM Hackathon

**Problem 1 — Reconfigurable 5×5 Matrix Computation Accelerator**