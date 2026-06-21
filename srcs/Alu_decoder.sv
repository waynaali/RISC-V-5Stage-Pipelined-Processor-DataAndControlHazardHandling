`timescale 1ns / 1ps
module Alu_decoder(
    input  logic       opb5,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic [1:0] ALUOp,
    output logic [2:0] ALUControl
);

    // Detect R-type subtraction instruction
    logic RtypeSub;
    assign RtypeSub = opb5 & funct7b5;

    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 3'b000; 
            2'b01: ALUControl = 3'b001; 
            default: begin
                case (funct3)
                    3'b000: ALUControl = (RtypeSub) ? 3'b001 : 3'b000; // SUB / ADD
                    3'b010: ALUControl = 3'b101;                         // SLT
                    3'b110: ALUControl = 3'b011;                         // OR
                    3'b111: ALUControl = 3'b010;                         // AND
                    default: ALUControl = 3'b000;                endcase
            end
        endcase
    end

endmodule

