`timescale 1ns / 1ps

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

logic lwStall;  // signal for load-use hazard detection

assign lwStall = ResultSrcE0 && ((Rs1D == RdE) || (Rs2D == RdE)) && (RdE != 0);

// Flush EX stage if load-use hazard or branch taken
assign FlushE = lwStall | PCSrcE;

// Flush Decode stage only if branch taken
assign FlushD = PCSrcE;

// Stall IF and Decode stages only on load-use hazard
assign StallF = lwStall;
assign StallD = lwStall;

endmodule
