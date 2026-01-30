`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025
// Design Name: 32-bit Register File
// Module Name: register_file
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module implements a 32x32-bit register file for the RISC-V processor.
//      It supports two asynchronous read ports and one synchronous write port.
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - Register x0 is hardwired to 0 (cannot be written).
//      - Initial values of all registers are set to 4 (can be modified as needed).
//////////////////////////////////////////////////////////////////////////////////

module register_file (
    input  logic        clk,   // Clock signal
    input  logic [4:0]  A1,    // Read address 1
    input  logic [4:0]  A2,    // Read address 2
    input  logic [4:0]  A3,    // Write address
    input  logic [31:0] wd3,   // Data to write
    input  logic        we,    // Write enable
    output logic [31:0] rd1,   // Read data 1
    output logic [31:0] rd2    // Read data 2
);

    // 32 registers, each 32-bit wide
    logic [31:0] rf [0:31];

    // Initialize all registers to 4 (except x0 which is hardwired to 0)
    initial begin
        for (int i = 0; i < 32; i++) begin
            rf[i] = 32'd4;
        end
    end

    // Synchronous write operation
    always_ff @(posedge clk) begin
        if (we && A3 != 0) begin
            rf[A3] <= wd3; // Write data to register unless it's x0
        end
    end

    // Asynchronous read operations
    assign rd1 = (A1 != 0) ? rf[A1] : 32'b0; // x0 always returns 0
    assign rd2 = (A2 != 0) ? rf[A2] : 32'b0; // x0 always returns 0

endmodule
