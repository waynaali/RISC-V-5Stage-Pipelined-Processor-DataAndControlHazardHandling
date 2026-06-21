`timescale 1ns / 1ps

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