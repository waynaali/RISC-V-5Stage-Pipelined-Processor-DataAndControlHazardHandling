`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: rvhazard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   Top-level pipelined RISC-V processor with hazard detection, forwarding, and 
//   data memory interface. Implements a 5-stage pipeline (IF, ID, EX, MEM, WB).
//   This module instantiates all pipeline registers, ALU, memories, and hazard/forwarding units.
//
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module rvhazard(
    input logic clk,        // Clock
    input logic reset       // Reset
);

/////////////////////////
// Pipeline Control Signals
/////////////////////////
logic ZeroE;             // ALU zero flag (used for branch decisions)
logic StallF, StallD;    // Pipeline stall signals for IF and ID stages
logic FlushE, FlushD;    // Pipeline flush signals for EX and ID stages
logic PCSrcE;            // PC source signal (branch/jump decision)

/////////////////////////
// Forwarding Unit Signals
/////////////////////////
logic [1:0] ForwardAE, ForwardBE; // Forwarding mux control for ALU inputs

/////////////////////////
// Control Signals
/////////////////////////
logic RegWriteM, RegWriteE, RegWriteW; // Register write signals
logic MemWriteM, MemWriteE;            // Memory write signals
logic JumpD, BranchD, JumpE, BranchE;  // Jump and branch signals
logic ALUSrcE, ALUSrcD;                // ALU source mux control
logic [1:0] ResultSrcD, ResultSrcE, ResultSrcM, ResultSrcW; // Result select signals
logic [2:0] ALUControlD, ALUControlE; // ALU control signals
logic [1:0] ImmSrcD;                   // Immediate source

/////////////////////////
// Data Signals
/////////////////////////
logic [31:0] SrcAE, SrcBE, SrcB;       // ALU input sources
logic [31:0] ALUResultE, ALUResultM, ALUResultW;
logic [31:0] ReadDataM, ReadDataW;    // Memory read data
logic [31:0] WriteDataE;               // Data to write to memory
logic [31:0] PCTargetE, PCNext;       // PC target and next PC
logic [31:0] ResultW;                  // Data to write back
logic [31:0] RD1D, RD2D;               // Register file outputs
logic [31:0] RD1E, RD2E, RD2M;        // EX/MEM stage data
logic [31:0] ALUResultM;               // MEM stage ALU result
logic [31:0] ImmExtendE, ImmExtendD;   // Extended immediate values

/////////////////////////
// PC and Instruction Signals
/////////////////////////
logic [31:0] InstrD, InstrF;
logic [31:0] PCD, PCE, PCF;
logic [31:0] PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W, PCPlus4F;

/////////////////////////
// Register Addresses
/////////////////////////
logic [4:0] rs1E, rs2E, Rs1D, Rs2D, rdE, rdM, rdW;

/////////////////////////
// PC Source Logic
/////////////////////////
assign PCSrcE = (BranchE & ZeroE) | JumpE;

/////////////////////////
// Module Instantiations
/////////////////////////

// Forwarding Unit
forwarding_unit forwarding_unit(
    .Rs2E(rs2E),
    .Rs1E(rs1E),
    .RdM(rdM),
    .RdW(rdW),
    .RegWriteM(RegWriteM),
    .RegWriteW(RegWriteW),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE)
);

// Adders for PC calculations
Adder PC_Plus_4(.A(PCF), .B(32'd4), .Sum(PCPlus4F));
Adder PC_Target(.A(PCE), .B(ImmExtendE), .Sum(PCTargetE));

// PC Mux
mux2 PC_Next(.d0(PCPlus4F), .d1(PCTargetE), .s(PCSrcE), .y(PCNext));

// Program Counter
program_counter ProgramCounter(.clk(clk), .reset(reset), .en(~StallF), .PCNext(PCNext), .PC(PCF));

// Instruction Memory
instr_mem instruction_memory(.A(PCF), .RD(InstrF));

// IF/ID Pipeline Register
IF_ID IF_ID(
    .clk(clk),
    .reset(reset),
    .flush(FlushD),
    .en(~StallD),
    .InstrF(InstrF),
    .PCF(PCF),
    .PCPlus4F(PCPlus4F),
    .InstrD(InstrD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D)
);

// Register File
register_file register_file(
    .clk(clk),
    .A1(InstrD[19:15]),
    .A2(InstrD[24:20]),
    .A3(rdW),
    .wd3(ResultW),
    .we(RegWriteW),
    .rd1(RD1D),
    .rd2(RD2D)
);

// Immediate Extend Unit
ExtendUnit Extend(.Instr(InstrD), .ImmSrc(ImmSrcD), .ImmExtend(ImmExtendD));

// Control Unit
control_unit control_unit(
    .op(InstrD[6:0]),
    .funct3(InstrD[14:12]),
    .funct7b5(InstrD[30]),
    .Branch(BranchD),
    .Jump(JumpD),
    .ResultSrc(ResultSrcD),
    .MemWrite(MemWriteD),
    .ImmSrc(ImmSrcD),
    .RegWrite(RegWriteD),
    .ALUSrc(ALUSrcD),
    .ALUControl(ALUControlD)
);

// Hazard Unit
HazardUnit hazard_unit(
    .Rs1D(InstrD[19:15]),
    .Rs2D(InstrD[24:20]),
    .RdE(rdE),
    .PCSrcE(PCSrcE),
    .ResultSrcE0(ResultSrcE[0]),
    .StallF(StallF),
    .StallD(StallD),
    .FlushE(FlushE),
    .FlushD(FlushD)
);

// ID/EX Pipeline Register
ID_IE ID_IE(
    .clk(clk),
    .reset(reset),
    .flush(FlushE),
    .rd1D(RD1D),
    .rd2D(RD2D),
    .PCD(PCD),
    .rs1D(InstrD[19:15]),
    .rs2D(InstrD[24:20]),
    .rdD(InstrD[11:7]),
    .ImmExtendD(ImmExtendD),
    .PCPlus4D(PCPlus4D),
    .RegWriteD(RegWriteD),
    .ResultSrcD(ResultSrcD),
    .MemWriteD(MemWriteD),
    .JumpD(JumpD),
    .BranchD(BranchD),
    .ALUSrcD(ALUSrcD),
    .ALUControlD(ALUControlD),
    .rd1E(RD1E),
    .rd2E(RD2E),
    .PCE(PCE),
    .rs1E(rs1E),
    .rs2E(rs2E),
    .rdE(rdE),
    .ImmExtendE(ImmExtendE),
    .PCPlus4E(PCPlus4E),
    .RegWriteE(RegWriteE),
    .ResultSrcE(ResultSrcE),
    .MemWriteE(MemWriteE),
    .JumpE(JumpE),
    .BranchE(BranchE),
    .ALUSrcE(ALUSrcE),
    .ALUControlE(ALUControlE)
);

// ALU operand selection with forwarding
mux2 Src_B(.d0(SrcB), .d1(ImmExtendE), .s(ALUSrcE), .y(SrcBE));
mux3to1 mux(.d0(RD1E), .d1(ResultW), .d2(ALUResultM), .s(ForwardAE), .y(SrcAE));
mux3to1 mux2(.d0(RD2E), .d1(ResultW), .d2(ALUResultM), .s(ForwardBE), .y(SrcB));

// ALU
ALU ALU(
    .SrcA(SrcAE),
    .SrcB(SrcBE),
    .ALUControl(ALUControlE),
    .ALUResult(ALUResultE),
    .Zero(ZeroE)
);

// EX/MEM Pipeline Register
IE_IM IE_IM(
    .clk(clk),
    .reset(reset),
    .ALUResultE(ALUResultE),
    .RD2E(RD2E),
    .RegWriteM(RegWriteM),
    .MemWriteM(MemWriteM),
    .ResultSrcM(ResultSrcM),
    .RegWriteE(RegWriteE),
    .MemWriteE(MemWriteE),
    .ResultSrcE(ResultSrcE),
    .rdE(rdE),
    .PCPlus4E(PCPlus4E),
    .ALUResultM(ALUResultM),
    .RD2M(RD2M),
    .rdM(rdM),
    .PCPlus4M(PCPlus4M)
);

// Data Memory
data_mem data_memory(
    .clk(clk),
    .we(MemWriteM),
    .A(ALUResultM),
    .WD(RD2M),
    .ReadData(ReadDataM)
);

// MEM/WB Pipeline Register
IM_IW IM_IW(
    .clk(clk),
    .reset(reset),
    .ALUResultM(ALUResultM),
    .ReadDataM(ReadDataM),
    .PCPlus4M(PCPlus4M),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .rdM(rdM),
    .ALUResultW(ALUResultW),
    .ReadDataW(ReadDataW),
    .PCPlus4W(PCPlus4W),
    .rdW(rdW),
    .RegWriteW(RegWriteW),
    .ResultSrcW(ResultSrcW)
);

// Result Selection for Write-back
mux3to1 result(
    .d0(ALUResultW),
    .d1(ReadDataW),
    .d2(PCPlus4W),
    .s(ResultSrcW),
    .y(ResultW)
);

endmodule
