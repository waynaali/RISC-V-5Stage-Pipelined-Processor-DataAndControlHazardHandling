`timescale 1ns / 1ps
module control_unit(
    input  logic [6:0] op,
    input  logic       Zero,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    output logic       Branch,
    output logic       Jump,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic [1:0] ImmSrc,
    output logic       RegWrite,
    output logic       ALUSrc,
    output logic [2:0] ALUControl
);
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
