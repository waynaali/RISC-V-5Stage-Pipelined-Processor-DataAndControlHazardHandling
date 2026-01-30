`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 11:58:00 AM
// Design Name: IM/IW Pipeline Register
// Module Name: IM_IW
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module implements the IM/IW pipeline register used in the 5-stage
//      RISC-V processor pipeline. It transfers signals from the Memory (IM) stage 
//      to the Write Back (IW) stage.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - Synchronous reset initializes all outputs to 0.
//      - Updates occur on the rising edge of the clock.
//////////////////////////////////////////////////////////////////////////////////

module IM_IW(
    input  logic        clk,        // Clock signal
    input  logic        reset,      // Synchronous reset
    input  logic [31:0] ALUResultM, // ALU result from Memory stage
    input  logic [31:0] ReadDataM,  // Data read from memory
    input  logic [31:0] PCPlus4M,   // PC+4 from Memory stage
    input  logic        RegWriteM,  // Control signals from Memory stage
    input  logic [1:0]  ResultSrcM,
    input  logic [4:0]  rdM,        // Destination register

    output logic [31:0] ALUResultW, // Outputs to Write Back stage
    output logic [31:0] ReadDataW,
    output logic [31:0] PCPlus4W,
    output logic [4:0]  rdW,
    output logic        RegWriteW,
    output logic [1:0]  ResultSrcW
);

    // Sequential logic for IM/IW pipeline register
    always_ff @(posedge clk) begin
        if (reset) begin
            // Reset all outputs to 0
            ALUResultW  <= 32'b0;
            ReadDataW   <= 32'b0;
            PCPlus4W    <= 32'b0;
            rdW         <= 5'b0;
            RegWriteW   <= 1'b0;
            ResultSrcW  <= 2'b0;
        end else begin
            // Transfer signals from Memory stage to Write Back stage
            ALUResultW  <= ALUResultM;
            ReadDataW   <= ReadDataM;
            PCPlus4W    <= PCPlus4M;
            rdW         <= rdM;
            RegWriteW   <= RegWriteM;
            ResultSrcW  <= ResultSrcM;
        end
    end

endmodule

