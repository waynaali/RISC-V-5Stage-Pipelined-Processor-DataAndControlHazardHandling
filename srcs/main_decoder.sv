`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 10:01:58 AM
// Design Name: Main Decoder
// Module Name: main_decoder
// Project Name: 5-Stage Pipelined RISC-V Processor
// Target Devices: FPGA / ASIC
// Tool Versions: Any SystemVerilog compatible
// Description: 
//      This module generates the primary control signals for the RISC-V processor
//      based on the opcode of the instruction. These signals are used for
//      ALU operation selection, register writes, memory access, branching, and jumps.
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - Uses a control vector internally for easier signal assignment.
//      - Supports load, store, R-type, I-type, branch, and JAL instructions.
//////////////////////////////////////////////////////////////////////////////////

module main_decoder(
    input  logic [6:0] op,         // Opcode from instruction
    output logic       RegWrite,    // Register write enable
    output logic [1:0] ResultSrc,  // Select source for result (ALU, Memory, PC+4)
    output logic [1:0] ALUOp,       // ALU operation code
    output logic [1:0] ImmSrc,     // Immediate type selector
    output logic       ALUSrc,      // ALU source select (register / immediate)
    output logic       MemWrite,    // Memory write enable
    output logic       Jump,        // Jump control
    output logic       Branch       // Branch control
);

    // Internal control vector:
    // {RegWrite, ImmSrc[1:0], ALUSrc, MemWrite, ResultSrc[1:0], Branch, ALUOp[1:0], Jump}
    logic [10:0] controls;

    // Assign vector bits to individual outputs
    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

    // Generate control signals based on opcode
    always_comb begin
        case (op)
            7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // Load (I-type)
            7'b0100011: controls = 11'b0_01_1_1_xx_0_00_0; // Store (S-type)
            7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type arithmetic
            7'b1100011: controls = 11'b0_10_0_0_xx_1_01_0; // Branch (B-type)
            7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type arithmetic
            7'b1101111: controls = 11'b1_11_x_0_10_0_xx_1; // JAL
            default:    controls = 11'b0_00_0_0_00_0_00_0; // Default: no operation
        endcase
    end

endmodule
