`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 11:56:56 AM
// Design Name: 
// Module Name: ID_IE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   This module implements the pipeline register between the ID (Instruction Decode)
//   and EX (Execute) stages in a pipelined RISC-V processor. 
//   It captures all signals from the ID stage and passes them to the EX stage 
//   on the rising edge of the clock. It also supports reset and flush functionality.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   - Flush is used to handle control hazards (e.g., after a branch misprediction).
//   - Reset clears all outputs to prevent unintended execution during initialization.
//   - This is a typical "pipeline register" module with synchronous logic.
//
//////////////////////////////////////////////////////////////////////////////////

module ID_IE(
    input logic clk,
    input logic reset,
    input logic flush,
    
    // Inputs from ID stage
    input logic [31:0] rd1D, rd2D,
    input logic [31:0] PCD,
    input logic [4:0] rs1D, rs2D, rdD,
    input logic [2:0] funct3D,
    input logic [31:0] ImmExtendD, PCPlus4D,
    input logic RegWriteD,
    input logic [1:0] ResultSrcD,
    input logic MemWriteD, JumpD, BranchD, ALUSrcD,
    input logic [2:0] ALUControlD,
    
    // Outputs to EX stage
    output logic [31:0] rd1E, rd2E,
    output logic [31:0] PCE,
    output logic [4:0] rs1E, rs2E, rdE,
    output logic [2:0] funct3E,
    output logic [31:0] ImmExtendE, PCPlus4E,
    output logic RegWriteE,
    output logic [1:0] ResultSrcE,
    output logic MemWriteE, JumpE, BranchE, ALUSrcE,
    output logic [2:0] ALUControlE
);

always_ff @(posedge clk) begin
    if (reset) begin
        rd1E <= 32'b0;
        rd2E <= 32'b0;
        PCE <= 32'b0;
        rs1E <= 5'b0;
        rs2E <= 5'b0;
        rdE <= 5'b0;
        funct3E <= 3'b0;
        ImmExtendE <= 32'b0;
        PCPlus4E <= 32'b0;
        RegWriteE <= 1'b0;
        ResultSrcE <= 2'b0;
        MemWriteE <= 1'b0;
        JumpE <= 1'b0;
        BranchE <= 1'b0;
        ALUSrcE <= 1'b0;
        ALUControlE <= 3'b0;
    end
    else if (flush) begin
        rd1E <= 32'b0;
        rd2E <= 32'b0;
        PCE <= 32'b0;
        rs1E <= 5'b0;
        rs2E <= 5'b0;
        rdE <= 5'b0;
        funct3E <= 3'b0;
        ImmExtendE <= 32'b0;
        PCPlus4E <= 32'b0;
        RegWriteE <= 1'b0;
        ResultSrcE <= 2'b0;
        MemWriteE <= 1'b0;
        JumpE <= 1'b0;
        BranchE <= 1'b0;
        ALUSrcE <= 1'b0;
        ALUControlE <= 3'b0;
    end
    else begin
        rd1E <= rd1D;
        rd2E <= rd2D;
        PCE <= PCD;
        rs1E <= rs1D;
        rs2E <= rs2D;
        rdE <= rdD;
        funct3E <= funct3D;
        ImmExtendE <= ImmExtendD;
        PCPlus4E <= PCPlus4D;
        RegWriteE <= RegWriteD;
        ResultSrcE <= ResultSrcD;
        MemWriteE <= MemWriteD;
        JumpE <= JumpD;
        BranchE <= BranchD;
        ALUSrcE <= ALUSrcD;
        ALUControlE <= ALUControlD;
    end
end

endmodule