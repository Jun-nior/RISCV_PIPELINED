# RISC-V Pipelined CPU with UVM Verification

![Language](https://img.shields.io/badge/Language-SystemVerilog-blue.svg)
![Verification](https://img.shields.io/badge/Verification-UVM-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

This repository contains the SystemVerilog RTL for a 32-bit, 5-stage **pipelined CPU** implementing the **RV32I base integer instruction set**. The design is validated by a comprehensive **UVM verification environment** featuring constrained-random stimulus, a pipeline-aware reference model for automatic checking, functional coverage, and formal assertions.

## Core CPU Features

### Pipelined Architecture
The CPU employs a classic 5-stage RISC-V pipeline to maximize instruction throughput:
1.  **IF:** Instruction Fetch
2.  **ID:** Instruction Decode & Register Read
3.  **EX:** Execute & Address Calculation
4.  **MEM:** Memory Access
5.  **WB:** Write-Back

### Hazard Handling
A complete hazard detection and resolution logic is implemented to ensure correct program execution:
* **Data Hazards:**
    * A **Forwarding Unit** resolves ALU-to-ALU data hazards (EX/MEM -> EX and MEM/WB -> EX) without stalling.
    * A **Hazard Detection Unit** specifically handles the **Load-Use Hazard** (`lw` followed by a dependent instruction) by stalling the pipeline for one cycle.
* **Control Hazards:**
    * Branch decisions (`BEQ`) are made in the EX stage.
    * A **flushing mechanism** is implemented to nullify instructions that were incorrectly fetched after a taken branch, preventing incorrect state changes.

### Supported Instruction Set
The processor supports a wide range of instructions, including:
* **R-type:** `ADD`, `SUB`, `AND`, `OR`, `XOR`
* **I-type:** `ADDI`, `ANDI`, `ORI`, `XORI`, `LW`
* **S-type:** `SW`
* **B-type:** `BEQ`

## Verification Environment (UVM)

A robust, reusable UVM testbench was created to thoroughly verify the CPU's functionality.

### Key Components
* **Multi-Agent Architecture:** The testbench is structured with multiple agents, each responsible for a specific pipeline interface (Fetch, Decode, Execute, Write-Back), allowing for targeted, white-box verification.
* **Constrained-Random Stimulus:** A highly configurable transaction item (`im_item`) with SystemVerilog constraints is used to generate a rich and diverse mix of legal instructions.
* **Pipeline-Aware Scoreboard:** A sophisticated scoreboard acts as a transaction-tracking reference model. It:
    * Tracks each instruction individually as it moves through the pipeline.
    * Simulates the CPU's forwarding logic to accurately predict results for dependent instructions (e.g., `ADD` followed by `BEQ`).
    * Handles instruction flushing due to taken branches to maintain synchronization with the DUT.
* **Functional Coverage:** A dedicated coverage collector with multiple `covergroups` listens to monitors at different pipeline stages to track key metrics:
    * **Instruction Mix:** Verifies that all implemented instruction types are generated (sampled at Fetch stage).
    * **Register Usage:** Tracks the usage of all source registers (`rs1`, `rs2`) from the Decode stage and destination registers (`rd`) from the Write-Back stage.
    * **Data Values:** Samples the distribution of data written to the register file and addresses/data used in memory operations.
* **SystemVerilog Assertions (SVA):** A dedicated checker module, bound to the DUT, formally verifies critical low-level hardware properties, such as:
    * **Reset Behavior:** Asserts that the Program Counter (PC) is correctly cleared on reset.
    * **Pipeline Control:** Verifies that the PC remains stable during a stall cycle.
    * **Control Signal Logic:** Checks for logical consistency, such as ensuring a taken branch (`PCSC_E`) originates from a branch instruction (`Branch_E`).
    * **Data Validity:** Asserts that data is valid during key operations, such as a write-back (`RegWrite_W`) or a memory write (`MemWrite`).

### Regression and Reporting

The verification flow is managed by a `Makefile` that supports:
* Running tests with specific or random seeds.
* Automated regression runs with multiple seeds.
* Merging coverage databases (`.ucdb`) from multiple runs.
* Generating detailed HTML coverage reports with annotated source code.
