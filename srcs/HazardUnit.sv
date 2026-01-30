`timescale 1ns / 1ps

// Hazard detection unit for a 5-stage pipelined RISC-V processor
// Handles load-use data hazards and control hazards (branches)
module HazardUnit(
    input  logic [4:0] Rs1D,       // Source register 1 in Decode stage
    input  logic [4:0] Rs2D,       // Source register 2 in Decode stage
    input  logic [4:0] RdE,        // Destination register in EX stage
    input  logic  PCSrcE,          // Branch taken signal in EX stage
    input  logic  ResultSrcE0,     // Load instruction signal in EX stage
    output logic StallF,           // Stall IF stage
    output logic StallD,           // Stall Decode stage
    output logic FlushE,           // Flush EX stage
    output logic FlushD            // Flush Decode stage
);

logic lwStall;  // Internal signal for load-use hazard detection

// Load-use hazard occurs when:
// - Instruction in EX is a load
// - Instruction in Decode reads a register being loaded
// - Destination register is not zero (x0)
assign lwStall = ResultSrcE0 && ((Rs1D == RdE) || (Rs2D == RdE)) && (RdE != 0);

// Flush EX stage if load-use hazard or branch taken
assign FlushE = lwStall | PCSrcE;

// Flush Decode stage only if branch taken
assign FlushD = PCSrcE;

// Stall IF and Decode stages only on load-use hazard
assign StallF = lwStall;
assign StallD = lwStall;

endmodule
