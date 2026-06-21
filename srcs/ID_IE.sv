`timescale 1ns / 1ps

module ID_IE(
    input  logic        clk,
    input  logic        reset,
    input  logic        flush,
    input  logic        en,

    input  logic [31:0] rd1D,
    input  logic [31:0] rd2D,
    input  logic [31:0] PCD,
    input  logic [4:0]  rs1D,
    input  logic [4:0]  rs2D,
    input  logic [4:0]  rdD,
    input  logic [31:0] ImmExtendD,
    input  logic [31:0] PCPlus4D,

    input  logic        RegWriteD,
    input  logic [1:0]  ResultSrcD,
    input  logic        MemWriteD,
    input  logic        JumpD,
    input  logic        BranchD,
    input  logic        ALUSrcD,
    input  logic [2:0]  ALUControlD,
    input  logic [2:0]  funct3D,

    output logic [31:0] rd1E,
    output logic [31:0] rd2E,
    output logic [31:0] PCE,
    output logic [4:0]  rs1E,
    output logic [4:0]  rs2E,
    output logic [4:0]  rdE,
    output logic [31:0] ImmExtendE,
    output logic [31:0] PCPlus4E,

    output logic        RegWriteE,
    output logic [1:0]  ResultSrcE,
    output logic        MemWriteE,
    output logic        JumpE,
    output logic        BranchE,
    output logic        ALUSrcE,
    output logic [2:0]  ALUControlE,
    output logic [2:0]  funct3E
);

    always_ff @(posedge clk) begin
        if (reset || flush) begin
            rd1E        <= 32'b0;
            rd2E        <= 32'b0;
            PCE         <= 32'b0;
            rs1E        <= 5'b0;
            rs2E        <= 5'b0;
            rdE         <= 5'b0;
            ImmExtendE  <= 32'b0;
            PCPlus4E    <= 32'b0;

            RegWriteE   <= 1'b0;
            ResultSrcE  <= 2'b0;
            MemWriteE   <= 1'b0;
            JumpE       <= 1'b0;
            BranchE     <= 1'b0;
            ALUSrcE     <= 1'b0;
            ALUControlE <= 3'b0;
            funct3E     <= 3'b0;
        end
        else if (en) begin
            rd1E        <= rd1D;
            rd2E        <= rd2D;
            PCE         <= PCD;
            rs1E        <= rs1D;
            rs2E        <= rs2D;
            rdE         <= rdD;
            ImmExtendE  <= ImmExtendD;
            PCPlus4E    <= PCPlus4D;

            RegWriteE   <= RegWriteD;
            ResultSrcE  <= ResultSrcD;
            MemWriteE   <= MemWriteD;
            JumpE       <= JumpD;
            BranchE     <= BranchD;
            ALUSrcE     <= ALUSrcD;
            ALUControlE <= ALUControlD;
            funct3E     <= funct3D;
        end
    end

endmodule