`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 09:03:51 AM
// Design Name: Immediate Extension Unit
// Module Name: ExtendUnit
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module extracts and sign-extends immediate values from the instruction
//      based on the instruction type (I-type, S-type, B-type, J-type).
//      The extended immediate is used in ALU calculations and branch target computation.
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - ImmSrc selects the type of immediate:
//          2'b00: I-type
//          2'b01: S-type
//          2'b10: B-type
//          2'b11: J-type
//      - Sign extension is performed according to RISC-V specification.
//////////////////////////////////////////////////////////////////////////////////

module ExtendUnit(
    input  logic [31:0] Instr,      // Instruction input
    input  logic [1:0]  ImmSrc,     // Immediate type selector
    output logic [31:0] ImmExtend   // Sign-extended immediate output
);

    // Combinational logic for immediate extraction and sign-extension
    always_comb begin
        case (ImmSrc)
            2'b00: ImmExtend = {{20{Instr[31]}}, Instr[31:20]};                        // I-type
            2'b01: ImmExtend = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};          // S-type
            2'b10: ImmExtend = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0}; // B-type
            2'b11: ImmExtend = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0}; // J-type
            default: ImmExtend = 32'b0;                                               // Default
        endcase
    end

endmodule
