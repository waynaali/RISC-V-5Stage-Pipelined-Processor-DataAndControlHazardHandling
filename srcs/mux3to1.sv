`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2025 09:41:40 AM
// Design Name: 3-to-1 Multiplexer
// Module Name: mux3to1
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module implements a 3-to-1 multiplexer used in the Write Back stage
//      to select the final result to be written back to the register file.
//      It selects between ALU result, data memory output, and PC+4 based on 
//      the ResultSrc control signal.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - Synchronous operation not required; purely combinational logic.
//////////////////////////////////////////////////////////////////////////////////

module mux3to1(
    input  logic [31:0] d0, // Input 0 (ALU result)
    input  logic [31:0] d1, // Input 1 (Memory read data)
    input  logic [31:0] d2, // Input 2 (PC + 4 for jumps)
    input  logic [1:0]  s,  // 2-bit select signal
    output logic [31:0] y   // Output
);

    // Combinational selection logic
    assign y = s[1] ? d2 : (s[0] ? d1 : d0);

endmodule
