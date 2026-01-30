`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 09:33:47 AM
// Design Name: ALU Decoder
// Module Name: Alu_decoder
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module generates the ALUControl signals based on the ALUOp signals 
//      from the main decoder and the instruction's funct3 and funct7 fields.
//      It handles both I-type and R-type instructions for arithmetic and logic operations.
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - Supports addition, subtraction, AND, OR, and SLT operations
//      - RtypeSub is used to detect R-type subtraction operation
//////////////////////////////////////////////////////////////////////////////////

module Alu_decoder(
    input  logic       opb5,        // Bit 5 of opcode (for distinguishing R-type sub)
    input  logic [2:0] funct3,      // funct3 field of instruction
    input  logic       funct7b5,    // Bit 5 of funct7 field (for subtraction)
    input  logic [1:0] ALUOp,       // ALU operation code from main decoder
    output logic [2:0] ALUControl   // ALU control signals
);

    // Detect R-type subtraction instruction
    logic RtypeSub;
    assign RtypeSub = opb5 & funct7b5;

    // Combinational logic to generate ALUControl signals
    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 3'b000; // Typically for load/store (add)
            2'b01: ALUControl = 3'b001; // Typically for branch (subtract)
            default: begin
                case (funct3)
                    3'b000: ALUControl = (RtypeSub) ? 3'b001 : 3'b000; // SUB / ADD
                    3'b010: ALUControl = 3'b101;                         // SLT
                    3'b110: ALUControl = 3'b011;                         // OR
                    3'b111: ALUControl = 3'b010;                         // AND
                    default: ALUControl = 3'bxxx;                        // Undefined
                endcase
            end
        endcase
    end

endmodule

