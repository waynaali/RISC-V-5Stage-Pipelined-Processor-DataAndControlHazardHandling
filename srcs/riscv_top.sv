`timescale 1ns / 1ps

module riscv_top(
    input logic clk,
    input logic reset
);

      // Pipeline Control Signals
    logic ZeroE;
    logic StallF, StallD;
    logic FlushE, FlushD;
    logic PCSrcE;
    logic [2:0] funct3E, funct3M;

      // I-Cache Signals
    logic [31:0] icache_mem_addr;
    logic [31:0] icache_mem_rdata;
    logic        icache_hit;
    logic        icache_stall;
    logic        icache_mem_req;
    logic        icache_mem_ready;

      // D-Cache Signals
    logic        dcache_hit;
    logic        dcache_stall;
    logic        dcache_mem_we;
    logic [3:0]  dcache_mem_be;
    logic [31:0] dcache_mem_addr;
    logic [31:0] dcache_mem_wdata;
    logic [31:0] dcache_mem_rdata;
    logic        dcache_mem_req;
    logic        dcache_mem_ready;

      // Forwarding Unit Signals
    logic [1:0] ForwardAE, ForwardBE;

      // Control Signals
    logic RegWriteD, RegWriteE, RegWriteM, RegWriteW;
    logic MemWriteD, MemWriteE, MemWriteM;
    logic JumpD, BranchD, JumpE, BranchE;
    logic ALUSrcE, ALUSrcD;

    logic [1:0] ResultSrcD, ResultSrcE, ResultSrcM, ResultSrcW;
    logic [2:0] ALUControlD, ALUControlE;
    logic [1:0] ImmSrcD;

      // Data Signals
    logic [31:0] SrcAE, SrcBE, SrcB;
    logic [31:0] ALUResultE, ALUResultM, ALUResultW;
    logic [31:0] ReadDataM, ReadDataW;
    logic [31:0] PCTargetE, PCNext;
    logic [31:0] ResultW;

    logic [31:0] RD1D, RD2D;
    logic [31:0] RD1E, RD2E, RD2M;
    logic [31:0] ImmExtendE, ImmExtendD;

    // New corrected store-data signal
    logic [31:0] StoreDataM;

      // PC and Instruction Signals
    logic [31:0] InstrD, InstrF;
    logic [31:0] PCD, PCE, PCF;
    logic [31:0] PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W, PCPlus4F;

      // Register Address Signals
    logic [4:0] rs1E, rs2E, rs2M, rdE, rdM, rdW;

      // Cache Stall Logic
    logic global_cache_stall;
    assign global_cache_stall = icache_stall | dcache_stall;

    // AXI4 Single-Beat Internal Signals
    // AXI4 Write Address Channel
    logic [31:0] axi_awaddr;
    logic [7:0]  axi_awlen;
    logic [2:0]  axi_awsize;
    logic [1:0]  axi_awburst;
    logic        axi_awvalid;
    logic        axi_awready;

    // AXI4 Write Data Channel
    logic [31:0] axi_wdata;
    logic [3:0]  axi_wstrb;
    logic        axi_wlast;
    logic        axi_wvalid;
    logic        axi_wready;

    // AXI4 Write Response Channel
    logic [1:0]  axi_bresp;
    logic        axi_bvalid;
    logic        axi_bready;

    // AXI4 Read Address Channel
    logic [31:0] axi_araddr;
    logic [7:0]  axi_arlen;
    logic [2:0]  axi_arsize;
    logic [1:0]  axi_arburst;
    logic        axi_arvalid;
    logic        axi_arready;

    // AXI4 Read Data Channel
    logic [31:0] axi_rdata;
    logic [1:0]  axi_rresp;
    logic        axi_rlast;
    logic        axi_rvalid;
    logic        axi_rready;

      // PC Source Logic
      always_comb begin
        PCSrcE = 1'b0;

        if (JumpE) begin
            PCSrcE = 1'b1;
        end
        else if (BranchE) begin
            case (funct3E)
                3'b000: PCSrcE =  ZeroE;                           // BEQ
                3'b001: PCSrcE = ~ZeroE;                           // BNE
                3'b100: PCSrcE = ($signed(SrcAE) <  $signed(SrcB)); // BLT
                3'b101: PCSrcE = ($signed(SrcAE) >= $signed(SrcB)); // BGE
                3'b110: PCSrcE = (SrcAE <  SrcB);                   // BLTU
                3'b111: PCSrcE = (SrcAE >= SrcB);                   // BGEU
                default: PCSrcE = 1'b0;
            endcase
        end
    end

      // Forwarding Unit
      forwarding_unit forwarding_unit_inst (
        .Rs2E       (rs2E),
        .Rs1E       (rs1E),
        .RdM        (rdM),
        .RdW        (rdW),
        .RegWriteM  (RegWriteM),
        .RegWriteW  (RegWriteW),
        .ForwardAE  (ForwardAE),
        .ForwardBE  (ForwardBE)
    );

      // Program Counter Logic
      Adder PC_Plus_4 (
        .A   (PCF),
        .B   (32'd4),
        .Sum (PCPlus4F)
    );

    Adder PC_Target (
        .A   (PCE),
        .B   (ImmExtendE),
        .Sum (PCTargetE)
    );

    mux2 PC_Next (
        .d0 (PCPlus4F),
        .d1 (PCTargetE),
        .s  (PCSrcE),
        .y  (PCNext)
    );

    program_counter ProgramCounter (
        .clk    (clk),
        .reset  (reset),
        .en     (~(StallF | global_cache_stall)),
        .PCNext (PCNext),
        .PC     (PCF)
    );

      // I-Cache
      icache instruction_cache (
        .clk       (clk),
        .rst       (reset),
        .flush     (PCSrcE),

        .cpu_addr  (PCF),
        .cpu_instr (InstrF),

        .hit       (icache_hit),
        .stall     (icache_stall),

        .mem_req   (icache_mem_req),
        .mem_addr  (icache_mem_addr),
        .mem_rdata (icache_mem_rdata),
        .mem_ready (icache_mem_ready)
    );

      // AXI4 Single-Beat Master
      cache_axi4_master axi_master_wrapper (
        .clk   (clk),
        .reset (reset),

        // I-Cache request
        .i_req   (icache_mem_req),
        .i_addr  (icache_mem_addr),
        .i_rdata (icache_mem_rdata),
        .i_ready (icache_mem_ready),

        // D-Cache request
        .d_req   (dcache_mem_req),
        .d_we    (dcache_mem_we),
        .d_be    (dcache_mem_be),
        .d_addr  (dcache_mem_addr),
        .d_wdata (dcache_mem_wdata),
        .d_rdata (dcache_mem_rdata),
        .d_ready (dcache_mem_ready),

        // AXI4 Write Address Channel
        .M_AXI_AWADDR  (axi_awaddr),
        .M_AXI_AWLEN   (axi_awlen),
        .M_AXI_AWSIZE  (axi_awsize),
        .M_AXI_AWBURST (axi_awburst),
        .M_AXI_AWVALID (axi_awvalid),
        .M_AXI_AWREADY (axi_awready),

        // AXI4 Write Data Channel
        .M_AXI_WDATA   (axi_wdata),
        .M_AXI_WSTRB   (axi_wstrb),
        .M_AXI_WLAST   (axi_wlast),
        .M_AXI_WVALID  (axi_wvalid),
        .M_AXI_WREADY  (axi_wready),

        // AXI4 Write Response Channel
        .M_AXI_BRESP   (axi_bresp),
        .M_AXI_BVALID  (axi_bvalid),
        .M_AXI_BREADY  (axi_bready),

        // AXI4 Read Address Channel
        .M_AXI_ARADDR  (axi_araddr),
        .M_AXI_ARLEN   (axi_arlen),
        .M_AXI_ARSIZE  (axi_arsize),
        .M_AXI_ARBURST (axi_arburst),
        .M_AXI_ARVALID (axi_arvalid),
        .M_AXI_ARREADY (axi_arready),

        // AXI4 Read Data Channel
        .M_AXI_RDATA   (axi_rdata),
        .M_AXI_RRESP   (axi_rresp),
        .M_AXI_RLAST   (axi_rlast),
        .M_AXI_RVALID  (axi_rvalid),
        .M_AXI_RREADY  (axi_rready)
    );

      // AXI4 RAM Simulation Model
    // Program instructions are loaded from inst.mem
      axi4_ram axi_memory (
        .clk   (clk),
        .reset (reset),

        // AXI4 Write Address Channel
        .S_AXI_AWADDR  (axi_awaddr),
        .S_AXI_AWLEN   (axi_awlen),
        .S_AXI_AWSIZE  (axi_awsize),
        .S_AXI_AWBURST (axi_awburst),
        .S_AXI_AWVALID (axi_awvalid),
        .S_AXI_AWREADY (axi_awready),

        // AXI4 Write Data Channel
        .S_AXI_WDATA   (axi_wdata),
        .S_AXI_WSTRB   (axi_wstrb),
        .S_AXI_WLAST   (axi_wlast),
        .S_AXI_WVALID  (axi_wvalid),
        .S_AXI_WREADY  (axi_wready),

        // AXI4 Write Response Channel
        .S_AXI_BRESP   (axi_bresp),
        .S_AXI_BVALID  (axi_bvalid),
        .S_AXI_BREADY  (axi_bready),

        // AXI4 Read Address Channel
        .S_AXI_ARADDR  (axi_araddr),
        .S_AXI_ARLEN   (axi_arlen),
        .S_AXI_ARSIZE  (axi_arsize),
        .S_AXI_ARBURST (axi_arburst),
        .S_AXI_ARVALID (axi_arvalid),
        .S_AXI_ARREADY (axi_arready),

        // AXI4 Read Data Channel
        .S_AXI_RDATA   (axi_rdata),
        .S_AXI_RRESP   (axi_rresp),
        .S_AXI_RLAST   (axi_rlast),
        .S_AXI_RVALID  (axi_rvalid),
        .S_AXI_RREADY  (axi_rready)
    );

      // IF/ID Pipeline Register
      IF_ID IF_ID_inst (
        .clk       (clk),
        .reset     (reset),
        .flush     (FlushD),
        .en        (~(StallD | global_cache_stall)),

        .InstrF    (InstrF),
        .PCF       (PCF),
        .PCPlus4F  (PCPlus4F),

        .InstrD    (InstrD),
        .PCD       (PCD),
        .PCPlus4D  (PCPlus4D)
    );

      // Decode Stage
      register_file register_file_inst (
        .clk  (clk),
        .A1   (InstrD[19:15]),
        .A2   (InstrD[24:20]),
        .A3   (rdW),
        .wd3  (ResultW),
        .we   (RegWriteW),
        .rd1  (RD1D),
        .rd2  (RD2D)
    );

    ExtendUnit Extend_inst (
        .Instr     (InstrD),
        .ImmSrc    (ImmSrcD),
        .ImmExtend (ImmExtendD)
    );

    control_unit control_unit_inst (
        .op         (InstrD[6:0]),
        .funct3     (InstrD[14:12]),
        .funct7b5   (InstrD[30]),

        .Branch     (BranchD),
        .Jump       (JumpD),
        .ResultSrc  (ResultSrcD),
        .MemWrite   (MemWriteD),
        .ImmSrc     (ImmSrcD),
        .RegWrite   (RegWriteD),
        .ALUSrc     (ALUSrcD),
        .ALUControl (ALUControlD)
    );

    HazardUnit hazard_unit_inst (
        .Rs1D        (InstrD[19:15]),
        .Rs2D        (InstrD[24:20]),
        .RdE         (rdE),
        .PCSrcE      (PCSrcE),
        .ResultSrcE0 (ResultSrcE[0]),

        .StallF      (StallF),
        .StallD      (StallD),
        .FlushE      (FlushE),
        .FlushD      (FlushD)
    );

      // ID/EX Pipeline Register
      ID_IE ID_IE_inst (
        .clk          (clk),
        .reset        (reset),
        .flush        (FlushE),
        .en           (~global_cache_stall),

        .rd1D         (RD1D),
        .rd2D         (RD2D),
        .PCD          (PCD),
        .rs1D         (InstrD[19:15]),
        .rs2D         (InstrD[24:20]),
        .rdD          (InstrD[11:7]),
        .ImmExtendD   (ImmExtendD),
        .PCPlus4D     (PCPlus4D),

        .RegWriteD    (RegWriteD),
        .ResultSrcD   (ResultSrcD),
        .MemWriteD    (MemWriteD),
        .JumpD        (JumpD),
        .BranchD      (BranchD),
        .ALUSrcD      (ALUSrcD),
        .ALUControlD  (ALUControlD),

        .rd1E         (RD1E),
        .rd2E         (RD2E),
        .PCE          (PCE),
        .rs1E         (rs1E),
        .rs2E         (rs2E),
        .rdE          (rdE),
        .ImmExtendE   (ImmExtendE),
        .PCPlus4E     (PCPlus4E),

        .RegWriteE    (RegWriteE),
        .ResultSrcE   (ResultSrcE),
        .MemWriteE    (MemWriteE),
        .JumpE        (JumpE),
        .BranchE      (BranchE),
        .ALUSrcE      (ALUSrcE),
        .ALUControlE  (ALUControlE),

        .funct3D      (InstrD[14:12]),
        .funct3E      (funct3E)
    );

      // Execute Stage
      mux3to1 mux_forward_a (
        .d0 (RD1E),
        .d1 (ResultW),
        .d2 (ALUResultM),
        .s  (ForwardAE),
        .y  (SrcAE)
    );

    mux3to1 mux_forward_b (
        .d0 (RD2E),
        .d1 (ResultW),
        .d2 (ALUResultM),
        .s  (ForwardBE),
        .y  (SrcB)
    );

    mux2 Src_B_mux (
        .d0 (SrcB),
        .d1 (ImmExtendE),
        .s  (ALUSrcE),
        .y  (SrcBE)
    );

    ALU ALU_inst (
        .SrcA       (SrcAE),
        .SrcB       (SrcBE),
        .ALUControl (ALUControlE),
        .ALUResult  (ALUResultE),
        .Zero       (ZeroE)
    );

      // EX/MEM Pipeline Register
      IE_IM IE_IM_inst (
        .clk         (clk),
        .reset       (reset),
        .en          (~global_cache_stall),

        .ALUResultE  (ALUResultE),
        .RD2E        (SrcB),
        .rs2E        (rs2E),

        .RegWriteE   (RegWriteE),
        .MemWriteE   (MemWriteE),
        .ResultSrcE  (ResultSrcE),
        .rdE         (rdE),
        .PCPlus4E    (PCPlus4E),
        .funct3E     (funct3E),

        .ALUResultM  (ALUResultM),
        .RD2M        (RD2M),
        .rs2M        (rs2M),

        .RegWriteM   (RegWriteM),
        .MemWriteM   (MemWriteM),
        .ResultSrcM  (ResultSrcM),
        .rdM         (rdM),
        .PCPlus4M    (PCPlus4M),
        .funct3M     (funct3M)
    );

      // MEM-Stage Store Data Forwarding
    // add x11, ... ; sw x11, 4(x10)
      always_comb begin
        StoreDataM = RD2M;

        if (MemWriteM && RegWriteW && (rdW != 5'd0) && (rdW == rs2M)) begin
            StoreDataM = ResultW;
        end
    end

      // D-Cache
      dcache data_cache (
        .clk       (clk),
        .rst       (reset),

        .mem_read  (ResultSrcM[0]),
        .mem_write (MemWriteM),
        .funct3    (funct3M),

        .cpu_addr  (ALUResultM),
        .cpu_wdata (StoreDataM),
        .cpu_rdata (ReadDataM),

        .hit       (dcache_hit),
        .stall     (dcache_stall),

        .mem_req   (dcache_mem_req),
        .mem_we    (dcache_mem_we),
        .mem_be    (dcache_mem_be),
        .mem_addr  (dcache_mem_addr),
        .mem_wdata (dcache_mem_wdata),
        .mem_rdata (dcache_mem_rdata),
        .mem_ready (dcache_mem_ready)
    );

      // MEM/WB Pipeline Register
      IM_IW IM_IW_inst (
        .clk         (clk),
        .reset       (reset),
        .en          (~global_cache_stall),

        .ALUResultM  (ALUResultM),
        .ReadDataM   (ReadDataM),
        .PCPlus4M    (PCPlus4M),
        .RegWriteM   (RegWriteM),
        .ResultSrcM  (ResultSrcM),
        .rdM         (rdM),

        .ALUResultW  (ALUResultW),
        .ReadDataW   (ReadDataW),
        .PCPlus4W    (PCPlus4W),
        .rdW         (rdW),
        .RegWriteW   (RegWriteW),
        .ResultSrcW  (ResultSrcW)
    );

      // Writeback Stage
      mux3to1 result_mux (
        .d0 (ALUResultW),
        .d1 (ReadDataW),
        .d2 (PCPlus4W),
        .s  (ResultSrcW),
        .y  (ResultW)
    );

endmodule