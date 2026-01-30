# RISC-V 5-Stage Pipelined Processor with Data and Control Hazard Handling

## Overview

This repository contains a **SystemVerilog implementation of a 5-stage pipelined RISC-V processor** with complete hazard handling support.  
The processor implements pipeline parallelism and resolves hazards using **forwarding, stall logic, and pipeline flushing**.

The design is modular, synthesizable, and verified through simulation waveforms in Vivado.

---

## ✨ Features

- ✅ 5-stage pipeline architecture  
- ✅ RISC-V instruction execution  
- ✅ Data hazard resolution using:
  - Forwarding paths
  - Load-use stall detection
- ✅ Control hazard handling using:
  - Branch Not Taken assumption
  - Pipeline flush on taken branch
- ✅ Separate Hazard Detection Unit
- ✅ Separate Forwarding Unit
- ✅ Modular RTL structure
- ✅ Simulation waveform verification

---

## 🧠 Pipeline Stages

1. **IF — Instruction Fetch**
2. **ID — Instruction Decode**
3. **EX — Execute**
4. **MEM — Memory Access**
5. **WB — Write Back**

Pipeline registers are implemented between each stage.

---

## ⚠️ Hazard Handling

### 🔹 Data Hazards

Handled using:

**Forwarding paths**
- MEM → EX forwarding
- WB → EX forwarding

**Load-Use Hazard**
- Pipeline stall inserted when needed

Control signals used:

```

ForwardAE
ForwardBE
StallF
StallD
FlushE

```

---

### 🔹 Control Hazards (Branches)

Branch strategy used:

> **Assume Branch Not Taken**

If branch is taken:

- PC is redirected to branch target
- Decode and Execute stages are flushed

Signals used:

```

PCSrcE
FlushD
FlushE

```

---
---

## 🧪 Simulation & Verification

Simulation performed in **Vivado**.

Verified behaviors:

- ✔ Correct pipeline instruction flow
- ✔ Forwarding activation
- ✔ Load-use stall cycles
- ✔ Branch flush behavior
- ✔ Register writeback correctness

Waveform screenshots are available.

---

## ▶️ How to Run

1. Open Vivado
2. Create new project
3. Add RTL files from `/rtl`
4. Add testbench from `/testbench`
5. Set testbench as top
6. Run simulation
7. Observe waveforms


## 🎯 Learning Goals

This project demonstrates:

- Pipeline processor design
- Hazard detection logic
- Forwarding networks
- Control hazard flushing
- Modular hardware design
- RTL verification

---

## 👩‍💻 Author

Wayna Ali  
RISC-V Pipelined CPU Project  
SystemVerilog | Computer Architecture | Digital Design

---

## 📌 Keywords

RISC-V, pipelined processor, hazard detection, forwarding unit, stall logic, control hazard, SystemVerilog, Vivado, CPU design
polish kar dete hain.

