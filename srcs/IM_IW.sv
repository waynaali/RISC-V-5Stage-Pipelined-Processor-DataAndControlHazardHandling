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
    input  logic        clk,
    input  logic        reset,
    input  logic        en,

    input  logic [31:0] ALUResultM,
    input  logic [31:0] ReadDataM,
    input  logic [31:0] PCPlus4M,
    input  logic        RegWriteM,
    input  logic [1:0]  ResultSrcM,
    input  logic [4:0]  rdM,

    output logic [31:0] ALUResultW,
    output logic [31:0] ReadDataW,
    output logic [31:0] PCPlus4W,
    output logic [4:0]  rdW,
    output logic        RegWriteW,
    output logic [1:0]  ResultSrcW
);

    always_ff @(posedge clk) begin
        if (reset) begin
            ALUResultW <= 32'b0;
            ReadDataW  <= 32'b0;
            PCPlus4W   <= 32'b0;
            rdW        <= 5'b0;
            RegWriteW  <= 1'b0;
            ResultSrcW <= 2'b0;
        end
        else if (en) begin
            ALUResultW <= ALUResultM;
            ReadDataW  <= ReadDataM;
            PCPlus4W   <= PCPlus4M;
            rdW        <= rdM;
            RegWriteW  <= RegWriteM;
            ResultSrcW <= ResultSrcM;
        end
    end

endmodule