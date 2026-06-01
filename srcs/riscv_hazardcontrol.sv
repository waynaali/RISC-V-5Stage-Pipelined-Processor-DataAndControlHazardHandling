`timescale 1ns / 1ps

module rvhazard(
    input logic clk,
    input logic reset
);

/////////////////////////
// Pipeline Control Signals
/////////////////////////
logic ZeroE;
logic StallF, StallD;
logic FlushE, FlushD;
logic PCSrcE;
logic [2:0] funct3E;

/////////////////////////
// I-Cache Signals
/////////////////////////
logic [31:0] icache_mem_addr;
logic [31:0] icache_mem_rdata;
logic        icache_hit;
logic        icache_stall;

/////////////////////////
// Forwarding Unit Signals
/////////////////////////
logic [1:0] ForwardAE, ForwardBE;

/////////////////////////
// Control Signals
/////////////////////////
logic RegWriteD, RegWriteE, RegWriteM, RegWriteW;
logic MemWriteD, MemWriteE, MemWriteM;
logic JumpD, BranchD, JumpE, BranchE;
logic ALUSrcE, ALUSrcD;
logic [1:0] ResultSrcD, ResultSrcE, ResultSrcM, ResultSrcW;
logic [2:0] ALUControlD, ALUControlE;
logic [1:0] ImmSrcD;

/////////////////////////
// Data Signals
/////////////////////////
logic [31:0] SrcAE, SrcBE, SrcB;
logic [31:0] ALUResultE, ALUResultM, ALUResultW;
logic [31:0] ReadDataM, ReadDataW;
logic [31:0] WriteDataE;
logic [31:0] PCTargetE, PCNext;
logic [31:0] ResultW;
logic [31:0] RD1D, RD2D;
logic [31:0] RD1E, RD2E, RD2M;
logic [31:0] ImmExtendE, ImmExtendD;

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
always_comb begin
    PCSrcE = 1'b0;

    if (JumpE) begin
        PCSrcE = 1'b1;
    end
    else if (BranchE) begin
        case (funct3E)
            3'b000: PCSrcE =  ZeroE;
            3'b001: PCSrcE = ~ZeroE;
            3'b100: PCSrcE = ($signed(SrcAE) < $signed(SrcB));
            3'b101: PCSrcE = ($signed(SrcAE) >= $signed(SrcB));
            3'b110: PCSrcE = (SrcAE < SrcB);
            3'b111: PCSrcE = (SrcAE >= SrcB);
            default: PCSrcE = 1'b0;
        endcase
    end
end

/////////////////////////
// Module Instantiations
/////////////////////////

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

Adder PC_Plus_4(.A(PCF), .B(32'd4), .Sum(PCPlus4F));
Adder PC_Target(.A(PCE), .B(ImmExtendE), .Sum(PCTargetE));

mux2 PC_Next(.d0(PCPlus4F), .d1(PCTargetE), .s(PCSrcE), .y(PCNext));

program_counter ProgramCounter(
    .clk(clk),
    .reset(reset),
    .en(~StallF),
    .PCNext(PCNext),
    .PC(PCF)
);

// I-Cache between PC and Instruction Memory
icache instruction_cache(
    .clk       (clk),
    .rst       (reset),
    .cpu_addr  (PCF),
    .cpu_instr (InstrF),
    .hit       (icache_hit),
    .stall     (icache_stall),
    .mem_addr  (icache_mem_addr),
    .mem_rdata (icache_mem_rdata)
);

// Lower Instruction Memory behind I-Cache
instr_mem instruction_memory(
    .A  (icache_mem_addr),
    .RD (icache_mem_rdata)
);

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

ExtendUnit Extend(
    .Instr(InstrD),
    .ImmSrc(ImmSrcD),
    .ImmExtend(ImmExtendD)
);

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
    .ALUControlE(ALUControlE),
    .funct3D(InstrD[14:12]),
    .funct3E(funct3E)
);

mux2 Src_B(
    .d0(SrcB),
    .d1(ImmExtendE),
    .s(ALUSrcE),
    .y(SrcBE)
);

mux3to1 mux(
    .d0(RD1E),
    .d1(ResultW),
    .d2(ALUResultM),
    .s(ForwardAE),
    .y(SrcAE)
);

mux3to1 mux2(
    .d0(RD2E),
    .d1(ResultW),
    .d2(ALUResultM),
    .s(ForwardBE),
    .y(SrcB)
);

ALU ALU(
    .SrcA(SrcAE),
    .SrcB(SrcBE),
    .ALUControl(ALUControlE),
    .ALUResult(ALUResultE),
    .Zero(ZeroE)
);

IE_IM IE_IM(
    .clk(clk),
    .reset(reset),
    .ALUResultE(ALUResultE),
    .RD2E(SrcB),
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

data_mem data_memory(
    .clk(clk),
    .we(MemWriteM),
    .A(ALUResultM),
    .WD(RD2M),
    .ReadData(ReadDataM)
);

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

mux3to1 result(
    .d0(ALUResultW),
    .d1(ReadDataW),
    .d2(PCPlus4W),
    .s(ResultSrcW),
    .y(ResultW)
);

endmodule