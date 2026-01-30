`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 11:30:01 AM
// Design Name: 
// Module Name: IF_ID
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   This module implements the pipeline register between the IF (Instruction Fetch)
//   and ID (Instruction Decode) stages of a pipelined RISC-V processor.
//   It captures the instruction and PC values from IF stage on the rising edge
//   of the clock and passes them to the ID stage. Supports reset, flush, and enable.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   - Flush is used to clear instructions after branch misprediction.
//   - Enable (en) allows stalling the pipeline without losing current instruction.
//   - Reset initializes the pipeline register to zero.
//
//////////////////////////////////////////////////////////////////////////////////

module IF_ID(
    input logic clk,           // Clock signal
    input logic reset,         // Synchronous reset
    input logic en,            // Enable signal (used for stalling)
    input logic flush,         // Flush signal (used to clear instruction on branch misprediction)
    
    // Inputs from IF stage
    input logic [31:0] InstrF,    // Instruction fetched from instruction memory
    input logic [31:0] PCF,       // Current program counter
    input logic [31:0] PCPlus4F,  // PC + 4 (for next sequential instruction)
    
    // Outputs to ID stage
    output logic [31:0] InstrD,   // Instruction for decode stage
    output logic [31:0] PCD,      // Program counter for decode stage
    output logic [31:0] PCPlus4D  // PC + 4 for decode stage
);

// Always block triggered on rising edge of clock
always_ff @(posedge clk) begin
    if (reset | flush) begin
        // On reset or flush, clear all outputs to prevent wrong instruction execution
        InstrD <= 32'b0;
        PCD <= 32'b0;
        PCPlus4D <= 32'b0;
    end
    else if (en) begin
        // Normal operation: pass instruction and PC values from IF stage to ID stage
        InstrD <= InstrF;
        PCD <= PCF;
        PCPlus4D <= PCPlus4F; 
    end
    // If en is 0 and not reset/flush, hold previous values (pipeline stall)
end

endmodule
