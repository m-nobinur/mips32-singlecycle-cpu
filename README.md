# CSE532 Final Project: MIPS MIN/MAX/MEAN

## Overview

Run a MIPS assembly program on the provided single-cycle CPU and compute:

- MEAN of 10 integers
- MAX of 10 integers
- MIN of 10 integers

Required data memory addresses:

- `Dmem[100]` -> MEAN
- `Dmem[120]` -> MAX
- `Dmem[140]` -> MIN

Workflow in this repository:

1. Assemble `mean_max_min.s` into machine-code binaries using `asmblr`.
2. Simulate the CPU with deterministic runtime (`repeat(300)`).
3. Dump memory snapshots into `MIPSVerilogWOJAL/generated/outputs/`.
4. Verify DMEM, REG, and IMEM checks with one script (`verify`).

## Input Data Used

The program uses this `.data` array in `MIPSVerilogWOJAL/mean_max_min.s`:

```
12, 7, 25, 3, 18, 30, 9, 21, 15, 6
```

Derived values:

- Sum = 146
- Integer mean = 14
- Max = 30
- Min = 3

## Expected Output

### Expected DMEM Results

- Dmem[100] = `00000000000000000000000000001110` (14)
- Dmem[120] = `00000000000000000000000000011110` (30)
- Dmem[140] = `00000000000000000000000000000011` (3)

### Expected REG Checks

- Reg[10] = `00000000000000000000000010010010` (146)  // sum ($t2)
- Reg[11] = `00000000000000000000000000011110` (30)   // max ($t3)
- Reg[12] = `00000000000000000000000000000011` (3)    // min ($t4)
- Reg[16] = `00000000000000000000000000001110` (14)   // mean ($s0)

### Expected IMEM Checks

- Imem[26] = `10101100000100000000000001100100`  // sw mean to 100($0)
- Imem[27] = `10101100000010110000000001111000`  // sw max  to 120($0)
- Imem[28] = `10101100000011000000000010001100`  // sw min  to 140($0)
- Imem[29] = `00001000000000000000000000011101`  // j halt

## Project Layout

- `asmblr` : MIPS assembler executable (pre-compiled from RoySRC's `UpgradedMIPS32Assembler`)
- `MIPSVerilogWOJAL/mean_max_min.s` : assembly program
- `MIPSVerilogWOJAL/*.v` : CPU RTL + testbench
- `MIPSVerilogWOJAL/generated/inputs/` : assembler outputs
- `MIPSVerilogWOJAL/generated/outputs/` : simulation outputs (`dmem.bin`, `reg.bin`, `imem.bin`)
- `verify` : single verification script

## Prerequisites

- macOS/Linux shell (Bash)
- `g++` (or `g++-15`) for assembler build
- `iverilog` and `vvp` for simulation
- `git` for repository workflow

## How To Use

### 0) Clone and enter the repository

```bash
git clone <your-repo-url>
cd assignment-final
```

### 1) Assemble (from project root)

```bash
mkdir -p MIPSVerilogWOJAL/generated/inputs MIPSVerilogWOJAL/generated/outputs
./asmblr MIPSVerilogWOJAL/mean_max_min.s MIPSVerilogWOJAL/generated/inputs/mean_max_min.out
```

### 2) Compile and run simulation (from MIPS folder)

```bash
cd MIPSVerilogWOJAL
iverilog -g2012 -o simv MIPS_SCP_tb.v MIPS_SCP.v
vvp simv
cd ..
```

Expected output files:

- `MIPSVerilogWOJAL/generated/outputs/dmem.bin`
- `MIPSVerilogWOJAL/generated/outputs/reg.bin`
- `MIPSVerilogWOJAL/generated/outputs/imem.bin`

### 3) Verify outputs (from project root)

```bash
./verify dmem -f MIPSVerilogWOJAL/generated/outputs/dmem.bin
./verify reg  -f MIPSVerilogWOJAL/generated/outputs/reg.bin
./verify imem -f MIPSVerilogWOJAL/generated/outputs/imem.bin
```

Target checks:
- `dmem`: addresses `100`, `120`, `140`
- `reg`: registers `10`, `11`, `12`, `16`
- `imem`: instruction slots `26`, `27`, `28`, `29`

## Constraints and Notes

- `verify` supports `dmem`, `reg`, and `imem` targets.
- `verify` accepts raw dump files only (annotated input is rejected).
- RAM is word-indexed in this project, so array traversal uses `+1` per element.
- Mean is implemented via repeated subtraction (`sum / 10`) since DIV is not used.
- Relative memory paths in RTL assume simulation is launched from `MIPSVerilogWOJAL/`.

## Acknowledgements

- Assembler source: UpgradedMIPS32Assembler by RoySRC
  https://github.com/RoySRC/UpgradedMIPS32Assembler
- `verify` script was written with GPT assistance and then manually reviewed/edited for this project.
- CPU RTL and testbench were adapted from the provided single-cycle CPU template.