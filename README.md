# MiniSRC CPU

A fully functional 32-bit RISC-style CPU designed and implemented in Verilog, the CPU is synthesized and deployed on the **Altera DE0-CV FPGA** development board.

---

## Overview

The MiniSRC is a 32-bit CPU based on a single-bus architecture. It supports a custom instruction set including arithmetic, logical, shift, memory, and branch operations. The design follows a multi-cycle execution model, with a dedicated control unit driving all datapath components through a finite state machine (FSM).

---

## Architecture

### Single-Bus Datapath
All internal data transfer happens over a shared 32-bit bus. Each register drives the bus through an output enable signal and latches data from the bus through an input enable signal, both controlled by the control unit.

### Key Components

| Module | Description |
|---|---|
| `CPU` | Top-level module — connects the control unit and datapath |
| `control_unit` | FSM-based instruction decoder — drives all control signals |
| `data_path` | Contains all registers, ALU, bus, and memory connections |
| `ALU` | 32-bit ALU supporting 13 operations |
| `Bus` | 32-bit bus multiplexer — selects which register drives the bus |
| `ram` | 512 × 32-bit synchronous RAM, initialized from a `.hex` file |
| `CLA_32` | 32-bit carry-lookahead adder (built from two 16-bit CLAs) |
| `CLA_16` | 16-bit carry-lookahead adder (built from four 4-bit CLAs) |
| `CLA_4` | 4-bit carry-lookahead adder using generate/propagate logic |
| `mult_32b` | 32-bit Booth's algorithm multiplier — 64-bit result |
| `div` | 32-bit non-restoring division — produces quotient and remainder |
| `con_ff` | Conditional flip-flop — evaluates branch conditions |
| `select_and_encode_logic` | Decodes IR register fields into register file enable signals |
| `pc_reg` | Program counter — supports load, increment, and reset |
| `mdr_reg` | MDR — selects between bus data and memory data |
| `register` | General-purpose 32-bit register |
| `register0` | R0 — forces output to 0 when BAout is asserted |

### Registers

| Register | Purpose |
|---|---|
| R0–R15 | General-purpose 32-bit registers (R0 hardwired to 0 for base addressing) |
| HI / LO | Hold the upper and lower 32 bits of MUL/DIV results |
| PC | Program counter |
| IR | Instruction register |
| MAR | Memory address register |
| MDR | Memory data register |
| Y | ALU input buffer |
| Z / ZHI | ALU result registers (low and high word) |

---

## Instruction Set

### R-Type (Register)
| Instruction | Op-Code | Description |
|---|---|---|
| `ADD` | `00000` | Ra ← Rb + Rc |
| `SUB` | `00001` | Ra ← Rb − Rc |
| `AND` | `00010` | Ra ← Rb AND Rc |
| `OR` | `00011` | Ra ← Rb OR Rc |
| `SHR` | `00100` | Ra ← Rb >> Rc (logical) |
| `SHRA` | `00101` | Ra ← Rb >>> Rc (arithmetic) |
| `SHL` | `00110` | Ra ← Rb << Rc |
| `ROR` | `00111` | Ra ← Rb rotate right Rc |
| `ROL` | `01000` | Ra ← Rb rotate left Rc |
| `MUL` | `01101` | HI:LO ← Ra × Rb |
| `DIV` | `01100` | LO ← Ra ÷ Rb, HI ← Ra mod Rb |
| `NEG` | `01110` | Ra ← −Rb |
| `NOT` | `01111` | Ra ← ~Rb |
| `MFHI` | `11000` | Ra ← HI |
| `MFLO` | `11001` | Ra ← LO |

### I-Type (Immediate)
| Instruction | Op-Code | Description |
|---|---|---|
| `ADDI` | `01001` | Ra ← Rb + C |
| `ANDI` | `01010` | Ra ← Rb AND C |
| `ORI` | `01011` | Ra ← Rb OR C |
| `LDI` | `10001` | Ra ← Rb + C |

### Memory
| Instruction | Op-Code | Description |
|---|---|---|
| `LD` | `10000` | Ra ← MEM[Rb + C] |
| `ST` | `10010` | MEM[Rb + C] ← Ra |

### Control Flow
| Instruction | Op-Code | Description |
|---|---|---|
| `JR` | `10011` | PC ← Ra |
| `JAL` | `10100` | Rb ← PC, PC ← Ra |
| `BRANCH` | `10101` | PC ← PC + C if condition met |

### I/O
| Instruction | Op-Code | Description |
|---|---|---|
| `IN` | `10110` | Ra ← In.Port |
| `OUT` | `10111` | Out.Port ← Ra |

### Miscellaneous
| Instruction | Op-Code | Description |
|---|---|---|
| `NOP` | `11010` | No operation |
| `HALT` | `11011` | Stop execution |

---

## FPGA I/O (DE0-CV)

| Signal | Pin | Description |
|---|---|---|
| `CLOCK_50` | — | 50 MHz on-board clock |
| `KEY0` | PIN_U7 | Reset (active-low) |
| `KEY1` | PIN_W9 | Stop (active-low) |
| `SW[7:0]` | PIN_U13–PIN_AA13 | CPU input port (In.Port) |
| `LEDS[5]` | PIN_N1 | Run indicator (ON = running, OFF = halted) |
| `HEX0` | — | Lower nibble of Out.Port |
| `HEX1` | — | Upper nibble of Out.Port |

---

## Project Structure
