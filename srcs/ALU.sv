`timescale 1ns / 1ps

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
            3'b000: ALUResult = SrcA + SrcB;                         // ADD
            3'b001: ALUResult = SrcA - SrcB;                         // SUB
            3'b010: ALUResult = SrcA & SrcB;                         // AND
            3'b011: ALUResult = SrcA | SrcB;                         // OR
            3'b101: ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 32'd1 : 32'd0; // SLT
            default: ALUResult = 32'b0;                              // Default to 0
        endcase

        // Set Zero flag
        Zero = (ALUResult == 0) ? 1'b1 : 1'b0;
    end

endmodule