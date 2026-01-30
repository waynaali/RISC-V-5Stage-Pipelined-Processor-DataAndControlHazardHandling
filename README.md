# RISC-V 5-Stage Pipelined Processor with Data & Control Hazard Handling

This repository contains a **SystemVerilog implementation of a 5-stage pipelined RISC-V processor** with complete hazard handling support. The processor implements pipeline parallelism and resolves hazards using **forwarding, stall logic, and pipeline flushing**.

The design is modular, synthesizable, and verified through simulation waveforms in Vivado.

---

## ✨ Features

- ✅ 5-stage pipeline architecture (IF, ID, EX, MEM, WB)  
- ✅ RISC-V instruction execution  
- ✅ Data hazard resolution using:
  - Forwarding paths (MEM→EX, WB→EX)
  - Load-use stall detection
- ✅ Control hazard handling:
  - Branch Not Taken assumption
  - Pipeline flush on taken branch
- ✅ Separate Hazard Detection Unit  
- ✅ Separate Forwarding Unit  
- ✅ Modular RTL structure in `/srcs`  
- ✅ Simulation waveform verification in `/doc`  

---

## Pipeline Stages

1. **IF** — Instruction Fetch  
2. **ID** — Instruction Decode  
3. **EX** — Execute / ALU Operations  
4. **MEM** — Memory Access  
5. **WB** — Write Back  

Pipeline registers are implemented between each stage to allow instruction overlap.

---

## ⚠️ Hazard Handling

### Data Hazards

Handled using:

- **Forwarding Paths:** MEM→EX and WB→EX  
- **Load-Use Hazard:** Pipeline stall inserted when needed  

Control signals used:

```

ForwardAE, ForwardBE, StallF, StallD, FlushE

```

### Control Hazards (Branches)

- Assume **Branch Not Taken**  
- If branch is taken:
  - PC redirected to branch target  
  - Decode and Execute stages flushed  

Control signals used:

```

PCSrcE, FlushD, FlushE

```

---

## Simulation & Verification

Simulation performed in **Vivado**. Verified behaviors:

- Correct pipeline instruction flow  
- Forwarding activation (MEM→EX / WB→EX)  
- Load-use stall cycles  
- Branch flush behavior  
- Register writeback correctness  

Waveform screenshots are available in `/doc`.

---

## How to Run

1. Open **Vivado**  
2. Create a new project  
3. Add RTL files from `/srcs`  
4. Add testbench from `/tb`  
5. Set testbench as top  
6. Run simulation  
7. Observe waveforms in `/doc`  

---

## Architecture Diagram

![Pipeline Diagram](doc/A_README_for_a_RISC-V_pipelined_processor_project_.png)

- Shows **pipeline stages, forwarding paths, stall cycles, and branch flush points**  

---

## Folder Structure

```

📦RISC-V-5Stage-Pipelined-Processor-DataAndControlHazardHandling
┣ 📂doc       # Architecture diagrams + waveform screenshots
┣ 📂instr_memory # Instruction memory contents
┣ 📂srcs      # RTL source files
┣ 📂tb        # Testbenches
┗ 📜README.md

```

---

## Keywords & SEO

```

RISC-V, 5-stage pipeline, SystemVerilog, forwarding, hazard detection, stall logic, control hazard, computer architecture, CPU design

```

---

## Learning Goals

- Pipeline processor design  
- Hazard detection logic  
- Forwarding networks  
- Control hazard flush handling  
- SystemVerilog RTL design and verification
```
