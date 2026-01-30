`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 03:41:13 PM
// Design Name: 32-bit 2-to-1 Multiplexer
// Module Name: mux2
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module implements a 32-bit 2-to-1 multiplexer used in the RISC-V processor
//      to select between two 32-bit input signals based on a single-bit selector.
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      The output y follows d0 when s=0 and d1 when s=1.
//      This is a purely combinational module without any clock dependency.
//////////////////////////////////////////////////////////////////////////////////

module mux2 (
    input  logic [31:0] d0, // Input 0
    input  logic [31:0] d1, // Input 1
    input  logic        s,  // Selector signal
    output logic [31:0] y   // Output
);

// Combinational MUX operation
assign y = s ? d1 : d0;

endmodule
