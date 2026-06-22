5-Stage Pipelined RV32I Processor with Cache-Based AXI4 Memory Subsystem
A SystemVerilog-based implementation and functional verification of a 5-stage pipelined RV32I processor integrated with instruction/data caches and an AXI4 memory subsystem. The design demonstrates pipelined instruction execution, hazard handling, cache-based memory communication, and simulation-based verification using a self-checking testbench.
Project Overview
The processor follows the standard 5-stage RISC-V pipeline:
•	Instruction Fetch (IF)
•	Instruction Decode (ID)
•	Execute (EX)
•	Memory Access (MEM)
•	Write Back (WB)
Pipeline registers are used between stages to support overlapping instruction execution. The design includes forwarding logic, hazard detection, stall control, and flush control to maintain correct program execution during data and control hazards.
Key Features
•	5-stage RV32I pipelined processor architecture
•	SystemVerilog RTL implementation
•	Instruction cache and data cache integration
•	AXI4 master interface for memory communication
•	AXI4 RAM behavioral memory model
•	Data hazard handling using forwarding and stall logic
•	Control hazard handling using flush control
•	Load and store support including LW, LB, LBU, LH, LHU, SW, SB, and SH
•	Self-checking SystemVerilog testbench
•	Console-based PASS/FAIL verification summary
•	Waveform-based debugging support using Vivado/XSim
Architecture Summary
The processor fetches instructions through the instruction cache and performs load/store operations through the data cache. Both caches communicate with the AXI4 master interface, which connects to a behavioral AXI4 RAM model. The verification environment checks processor execution, register writeback, store transactions, AXI4 read/write activity, and protocol control behavior.
Directed Verification Checks
The verification includes directed functional and protocol checks for:
•	ALU and register writeback correctness
•	Load instructions: LW, LB, LBU, LH, and LHU
•	Store instructions: SW, SB, and SH
•	AXI4 read and write channel activity
•	AXI4 single-beat transfer control
•	Forwarding and hazard-related behavior
•	Unexpected register write detection
•	Invalid instruction fetch detection before completion
Tools
•	SystemVerilog
•	Vivado / XSim
•	TCL
•	Waveform analysis
How to Run Simulation
1.	Open the project in Vivado.
2.	Add all RTL files from the srcs directory.
3.	Add the testbench files from the tb directory.
4.	Set tb_risc as the simulation top module.
5.	Set the project directory path in the Vivado TCL console.
6.	Run the TCL simulation script:
source tb/tb_risc.tcl
7.	Check the console output for the final verification summary.
Final Verification Result
The self-checking testbench reports the final simulation result in the console:
FINAL RESULT: TEST PASSED 

