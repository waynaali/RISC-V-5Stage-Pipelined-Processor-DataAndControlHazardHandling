`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 03:28:05 PM
// Design Name: 32-bit Adder
// Module Name: Adder
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module implements a simple 32-bit adder used in the RISC-V processor 
//      for calculating PC+4, branch/jump target addresses, or any arithmetic addition.
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      This module is purely combinational and produces Sum in the same clock cycle
//      without any pipeline registers.
// 
//////////////////////////////////////////////////////////////////////////////////

module Adder(
    input logic [31:0] A,   // First operand
    input logic [31:0] B,   // Second operand
    output logic [31:0] Sum // Result of A + B
);

// Combinational addition
assign Sum = A + B;

endmodule
