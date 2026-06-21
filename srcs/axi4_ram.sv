`timescale 1ns / 1ps

module axi4_ram (
    input  logic        clk,
    input  logic        reset,

    // AXI4 Write Address Channel
    input  logic [31:0] S_AXI_AWADDR,
    input  logic [7:0]  S_AXI_AWLEN,
    input  logic [2:0]  S_AXI_AWSIZE,
    input  logic [1:0]  S_AXI_AWBURST,
    input  logic        S_AXI_AWVALID,
    output logic        S_AXI_AWREADY,

    // AXI4 Write Data Channel
    input  logic [31:0] S_AXI_WDATA,
    input  logic [3:0]  S_AXI_WSTRB,
    input  logic        S_AXI_WLAST,
    input  logic        S_AXI_WVALID,
    output logic        S_AXI_WREADY,

    // AXI4 Write Response Channel
    output logic [1:0]  S_AXI_BRESP,
    output logic        S_AXI_BVALID,
    input  logic        S_AXI_BREADY,

    // AXI4 Read Address Channel
    input  logic [31:0] S_AXI_ARADDR,
    input  logic [7:0]  S_AXI_ARLEN,
    input  logic [2:0]  S_AXI_ARSIZE,
    input  logic [1:0]  S_AXI_ARBURST,
    input  logic        S_AXI_ARVALID,
    output logic        S_AXI_ARREADY,

    // AXI4 Read Data Channel
    output logic [31:0] S_AXI_RDATA,
    output logic [1:0]  S_AXI_RRESP,
    output logic        S_AXI_RLAST,
    output logic        S_AXI_RVALID,
    input  logic        S_AXI_RREADY
);

    localparam int RAM_DEPTH = 256;

    logic [31:0] RAM [0:RAM_DEPTH-1];

    logic [7:0] aw_index;
    logic [7:0] ar_index;

    assign aw_index = S_AXI_AWADDR[9:2];
    assign ar_index = S_AXI_ARADDR[9:2];

    assign S_AXI_AWREADY = 1'b1;
    assign S_AXI_WREADY  = 1'b1;
    assign S_AXI_ARREADY = 1'b1;

    assign S_AXI_BRESP = 2'b00;
    assign S_AXI_RRESP = 2'b00;

    integer i;

    initial begin
        for (i = 0; i < RAM_DEPTH; i = i + 1) begin
            RAM[i] = 32'h00000013;   // NOP
        end

        $readmemh("inst.mem", RAM);
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            S_AXI_BVALID <= 1'b0;
            S_AXI_RVALID <= 1'b0;
            S_AXI_RLAST  <= 1'b0;
            S_AXI_RDATA  <= 32'b0;
        end
        else begin
            if (S_AXI_AWVALID && S_AXI_AWREADY &&
                S_AXI_WVALID  && S_AXI_WREADY) begin

                if (S_AXI_WSTRB[0])
                    RAM[aw_index][7:0] <= S_AXI_WDATA[7:0];

                if (S_AXI_WSTRB[1])
                    RAM[aw_index][15:8] <= S_AXI_WDATA[15:8];

                if (S_AXI_WSTRB[2])
                    RAM[aw_index][23:16] <= S_AXI_WDATA[23:16];

                if (S_AXI_WSTRB[3])
                    RAM[aw_index][31:24] <= S_AXI_WDATA[31:24];

                S_AXI_BVALID <= 1'b1;
            end

            if (S_AXI_BVALID && S_AXI_BREADY) begin
                S_AXI_BVALID <= 1'b0;
            end

            if (S_AXI_ARVALID && S_AXI_ARREADY && !S_AXI_RVALID) begin
                S_AXI_RDATA  <= RAM[ar_index];
                S_AXI_RVALID <= 1'b1;
                S_AXI_RLAST  <= 1'b1;
            end

            if (S_AXI_RVALID && S_AXI_RREADY) begin
                S_AXI_RVALID <= 1'b0;
                S_AXI_RLAST  <= 1'b0;
            end
        end
    end

endmodule