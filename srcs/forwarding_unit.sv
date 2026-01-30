`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 08:42:09 AM
// Design Name: 
// Module Name: hazard_unt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   Forwarding Unit for a pipelined RISC-V processor. 
//   Resolves data hazards by forwarding results from later pipeline stages
//   (EX/MEM or MEM/WB) to the EX stage operands when needed.
//
//   ForwardAE and ForwardBE control the ALU input multiplexers for source operands.
//
// Inputs:
//   Rs1E, Rs2E : Source registers in EX stage
//   RdM        : Destination register in MEM stage
//   RdW        : Destination register in WB stage
//   RegWriteM  : Indicates MEM stage instruction will write to a register
//   RegWriteW  : Indicates WB stage instruction will write to a register
//
// Outputs:
//   ForwardAE  : Forwarding control for ALU input A
//   ForwardBE  : Forwarding control for ALU input B
//
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module forwarding_unit(
    input logic [4:0] Rs1E, Rs2E,   // Source registers in EX stage
    input logic [4:0] RdM, RdW,     // Destination registers in MEM and WB stages
    input logic RegWriteM, RegWriteW, // Control signals: indicate write-back to registers
    output logic [1:0] ForwardAE, ForwardBE // Forwarding signals to ALU muxes
);

// Combinational logic to determine forwarding
always_comb begin

    // Forward for ALU input A (rs1)
    if ((Rs1E == RdM) && RegWriteM && (Rs1E != 0)) begin
        // Case 1: EX stage source matches MEM stage destination
        // Forward result from MEM stage to EX stage input A
        ForwardAE = 2'b10;
    end
    else if ((Rs1E == RdW) && RegWriteW && (Rs1E != 0)) begin
        // Case 2: EX stage source matches WB stage destination
        // Forward result from WB stage to EX stage input A
        ForwardAE = 2'b01;
    end
    else begin
        // No forwarding needed, use value from register file
        ForwardAE = 2'b00;
    end

    // Forward for ALU input B (rs2)
    if ((Rs2E == RdM) && RegWriteM && (Rs2E != 0)) begin
        // Case 1: EX stage source matches MEM stage destination
        ForwardBE = 2'b10;
    end
    else if ((Rs2E == RdW) && RegWriteW && (Rs2E != 0)) begin
        // Case 2: EX stage source matches WB stage destination
        ForwardBE = 2'b01;
    end
    else begin
        // No forwarding needed
        ForwardBE = 2'b00;
    end

end

endmodule
