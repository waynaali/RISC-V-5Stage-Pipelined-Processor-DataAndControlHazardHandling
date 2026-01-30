`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 04:59:58 PM
// Design Name: Arithmetic Logic Unit (ALU)
// Module Name: ALU
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module implements the 32-bit ALU used in the Execute stage of the
//      5-stage pipelined RISC-V processor. It performs arithmetic and logic
//      operations based on the ALUControl signal.
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - Supports ADD, SUB, AND, OR, and shift-right operations.
//      - Outputs a Zero flag for branch decisions.
//////////////////////////////////////////////////////////////////////////////////

module ALU(
    input  logic [31:0] SrcA,      // Operand A
    input  logic [31:0] SrcB,      // Operand B
    input  logic [2:0]  ALUControl,// ALU operation selector
    output logic [31:0] ALUResult, // ALU result
    output logic        Zero       // Zero flag (set if ALUResult == 0)
);

    // Combinational ALU logic
    always_comb begin
        case (ALUControl)
            3'b000: ALUResult = SrcA + SrcB;   // ADD
            3'b001: ALUResult = SrcA - SrcB;   // SUB
            3'b101: ALUResult = SrcA >> SrcB;  // Shift Right
            3'b011: ALUResult = SrcA | SrcB;   // OR
            3'b010: ALUResult = SrcA & SrcB;   // AND
            default: ALUResult = 32'b0;        // Default to 0
        endcase

        // Set Zero flag
        Zero = (ALUResult == 0) ? 1'b1 : 1'b0;
    end

endmodule
