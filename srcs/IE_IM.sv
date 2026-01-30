`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 11:45:14 AM
// Design Name: IE/IM Pipeline Register
// Module Name: IE_IM
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module implements the IE/IM pipeline register used in the 5-stage
//      RISC-V processor pipeline. It transfers execution stage results and 
//      control signals from the Execute (IE) stage to the Memory (IM) stage.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - Synchronous reset initializes all outputs to 0.
//      - Updates occur on the rising edge of the clock.
//////////////////////////////////////////////////////////////////////////////////

module IE_IM(
    input  logic        clk,        // Clock signal
    input  logic        reset,      // Synchronous reset
    input  logic [31:0] ALUResultE, // ALU result from Execute stage
    input  logic [31:0] RD2E,       // Source register value for store
    input  logic        RegWriteE,  // Control signals from Execute stage
    input  logic        MemWriteE,
    input  logic [1:0]  ResultSrcE,
    input  logic [4:0]  rdE,        // Destination register
    input  logic [31:0] PCPlus4E,   // PC+4 from Execute stage

    output logic [31:0] ALUResultM, // Outputs to Memory stage
    output logic [31:0] RD2M,
    output logic        RegWriteM,
    output logic        MemWriteM,
    output logic [1:0]  ResultSrcM,
    output logic [4:0]  rdM,
    output logic [31:0] PCPlus4M
);

    // Sequential logic for IE/IM pipeline register
    always_ff @(posedge clk) begin
        if (reset) begin
            // Reset all outputs to 0
            ALUResultM  <= 32'b0;
            RD2M        <= 32'b0;
            rdM         <= 5'b0;
            PCPlus4M    <= 32'b0;
            RegWriteM   <= 1'b0;
            MemWriteM   <= 1'b0;
            ResultSrcM  <= 2'b0;
        end else begin
            // Transfer signals from Execute stage to Memory stage
            ALUResultM  <= ALUResultE;
            RD2M        <= RD2E;
            rdM         <= rdE;
            PCPlus4M    <= PCPlus4E;
            RegWriteM   <= RegWriteE;
            MemWriteM   <= MemWriteE;
            ResultSrcM  <= ResultSrcE;
        end
    end

endmodule

