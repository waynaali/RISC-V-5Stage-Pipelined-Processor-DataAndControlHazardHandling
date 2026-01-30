`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2025 09:56:13 AM
// Design Name: Data Memory
// Module Name: data_mem
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module implements a 32-bit wide data memory used in the Memory (IM)
//      stage of the 5-stage pipelined RISC-V processor. It supports synchronous
//      write and asynchronous read operations.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - Memory depth is 64 words (32-bit each).
//      - Address is word-aligned (A[31:2] used for indexing).
//////////////////////////////////////////////////////////////////////////////////

module data_mem(
    input  logic        clk,      // Clock signal
    input  logic        we,       // Write enable
    input  logic [31:0] A,        // Address for memory access
    input  logic [31:0] WD,       // Data to write
    output logic [31:0] ReadData  // Data read from memory
);

    // Memory array (64 words, 32-bit each)
    logic [31:0] dm [63:0];
    integer i;

    // Initialize memory to 0
    initial begin
        for (i = 0; i < 64; i = i + 1)
            dm[i] = 32'd0;
    end

    // Asynchronous read
    assign ReadData = dm[A[31:2]];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (we)
            dm[A[31:2]] <= WD;
    end

endmodule
