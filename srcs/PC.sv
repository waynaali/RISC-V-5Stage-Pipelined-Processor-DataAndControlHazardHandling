`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: program_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   This module implements a 32-bit program counter (PC) for a pipelined RISC-V
//   processor. The PC holds the address of the current instruction and updates
//   to PCNext on each clock cycle if enabled. Supports synchronous enable and 
//   asynchronous reset.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module program_counter(
    input  logic        clk,      // Clock signal
    input  logic        reset,    // Asynchronous reset signal
    input  logic        en,       // Enable signal (used to stall the PC)
    input  logic [31:0] PCNext,   // Next PC value to load
    output logic [31:0] PC        // Current PC value
);

// Always block triggered on rising edge of clock or asynchronous reset
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        // On reset, initialize PC to 0
        PC <= 32'h00000000;
    end
    else if (en) begin
        // Update PC to PCNext only if enable is high (used for stalling)
        PC <= PCNext;
    end
    // If enable is 0, PC holds its previous value (stall)
end

endmodule
