`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 09:55:00 AM
// Design Name: Control Unit
// Module Name: control_unit
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module implements the control unit of the RISC-V processor.
//      It generates all control signals required for instruction execution
//      based on the opcode and function fields of the instruction.
//      The control unit consists of a main decoder and an ALU decoder.
// 
// Dependencies: main_decoder, Alu_decoder
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - ALUControl is generated based on opcode, funct3, and funct7[5].
//      - Control signals include RegWrite, MemWrite, ALUSrc, Branch, Jump, ResultSrc, ImmSrc.
//////////////////////////////////////////////////////////////////////////////////

module control_unit(
    input  logic [6:0] op,        // Opcode from instruction
    input  logic       Zero,       // Zero flag from ALU (for branch decisions)
    input  logic [2:0] funct3,    // funct3 field from instruction
    input  logic       funct7b5,  // Bit 5 of funct7 field
    output logic       Branch,     // Branch control signal
    output logic       Jump,       // Jump control signal
    output logic [1:0] ResultSrc, // Result source selector (ALU / Memory / PC+4)
    output logic       MemWrite,   // Memory write enable
    output logic [1:0] ImmSrc,    // Immediate type selector
    output logic       RegWrite,   // Register write enable
    output logic       ALUSrc,     // ALU source select (register / immediate)
    output logic [2:0] ALUControl // ALU control signals
);

    // Intermediate ALUOp signals from main decoder to ALU decoder
    logic [1:0] ALUOp;

    // Instantiate ALU decoder to generate ALUControl signals
    Alu_decoder ad(
        .opb5(op[5]),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .ALUOp(ALUOp),
        .ALUControl(ALUControl)
    );

    // Instantiate main decoder to generate primary control signals
    main_decoder md(
        .op(op),
        .RegWrite(RegWrite),
        .ResultSrc(ResultSrc),
        .ALUOp(ALUOp),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .Jump(Jump),
        .Branch(Branch)
    );

endmodule
