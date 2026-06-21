`timescale 1ns / 1ps

module ExtendUnit(
    input  logic [31:0] Instr,
    input  logic [1:0]  ImmSrc,
    output logic [31:0] ImmExtend
);

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
