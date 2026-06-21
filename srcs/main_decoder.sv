`timescale 1ns / 1ps

module main_decoder(
    input  logic [6:0] op,
    output logic       RegWrite,
    output logic [1:0] ResultSrc,
    output logic [1:0] ALUOp,
    output logic [1:0] ImmSrc,
    output logic       ALUSrc,
    output logic       MemWrite,
    output logic       Jump,
    output logic       Branch
);

    logic [10:0] controls;

    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

    always_comb begin
        case (op)
            7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // Load
            7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // Store
            7'b0110011: controls = 11'b1_00_0_0_00_0_10_0; // R-type
            7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // Branch
            7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type arithmetic
            7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // JAL
            default:    controls = 11'b0_00_0_0_00_0_00_0; // NOP
        endcase
    end

endmodule