`timescale 1ns / 1ps

module cache_axi4_master (
    input  logic        clk,
    input  logic        reset,

    // I-Cache request
    input  logic        i_req,
    input  logic [31:0] i_addr,
    output logic [31:0] i_rdata,
    output logic        i_ready,

    // D-Cache request
    input  logic        d_req,
    input  logic        d_we,
    input  logic [3:0]  d_be,
    input  logic [31:0] d_addr,
    input  logic [31:0] d_wdata,
    output logic [31:0] d_rdata,
    output logic        d_ready,

    // AXI4 Write Address Channel
    output logic [31:0] M_AXI_AWADDR,
    output logic [7:0]  M_AXI_AWLEN,
    output logic [2:0]  M_AXI_AWSIZE,
    output logic [1:0]  M_AXI_AWBURST,
    output logic        M_AXI_AWVALID,
    input  logic        M_AXI_AWREADY,

    // AXI4 Write Data Channel
    output logic [31:0] M_AXI_WDATA,
    output logic [3:0]  M_AXI_WSTRB,
    output logic        M_AXI_WLAST,
    output logic        M_AXI_WVALID,
    input  logic        M_AXI_WREADY,

    // AXI4 Write Response Channel
    input  logic [1:0]  M_AXI_BRESP,
    input  logic        M_AXI_BVALID,
    output logic        M_AXI_BREADY,

    // AXI4 Read Address Channel
    output logic [31:0] M_AXI_ARADDR,
    output logic [7:0]  M_AXI_ARLEN,
    output logic [2:0]  M_AXI_ARSIZE,
    output logic [1:0]  M_AXI_ARBURST,
    output logic        M_AXI_ARVALID,
    input  logic        M_AXI_ARREADY,

    // AXI4 Read Data Channel
    input  logic [31:0] M_AXI_RDATA,
    input  logic [1:0]  M_AXI_RRESP,
    input  logic        M_AXI_RLAST,
    input  logic        M_AXI_RVALID,
    output logic        M_AXI_RREADY
);

    typedef enum logic [2:0] {
        IDLE,
        READ_ADDR,
        READ_DATA,
        WRITE_ADDR_DATA,
        WRITE_RESP,
        WAIT_D_REQ_DROP
    } state_t;

    state_t state;

    logic active_is_d;
    logic aw_done;
    logic w_done;

    // AXI4 single-beat fixed control signals
    assign M_AXI_AWLEN   = 8'd0;
    assign M_AXI_AWSIZE  = 3'b010;   // 4 bytes
    assign M_AXI_AWBURST = 2'b01;    // INCR

    assign M_AXI_ARLEN   = 8'd0;
    assign M_AXI_ARSIZE  = 3'b010;   // 4 bytes
    assign M_AXI_ARBURST = 2'b01;    // INCR

    assign M_AXI_WLAST   = M_AXI_WVALID;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;

            M_AXI_AWADDR  <= 32'b0;
            M_AXI_AWVALID <= 1'b0;

            M_AXI_WDATA   <= 32'b0;
            M_AXI_WSTRB   <= 4'b0000;
            M_AXI_WVALID  <= 1'b0;

            M_AXI_BREADY  <= 1'b0;

            M_AXI_ARADDR  <= 32'b0;
            M_AXI_ARVALID <= 1'b0;

            M_AXI_RREADY  <= 1'b0;

            i_rdata <= 32'b0;
            d_rdata <= 32'b0;
            i_ready <= 1'b0;
            d_ready <= 1'b0;

            active_is_d <= 1'b0;
            aw_done     <= 1'b0;
            w_done      <= 1'b0;
        end
        else begin
            // Default pulses.
            // NOTE: d_ready is NOT cleared in WAIT_D_REQ_DROP.
            // It is held high there until d_req becomes 0.
            i_ready <= 1'b0;

            if (state != WAIT_D_REQ_DROP) begin
                d_ready <= 1'b0;
            end

            case (state)

                // IDLE: accept D-cache first, then I-cache
                IDLE: begin
                    M_AXI_AWVALID <= 1'b0;
                    M_AXI_WVALID  <= 1'b0;
                    M_AXI_BREADY  <= 1'b0;
                    M_AXI_ARVALID <= 1'b0;
                    M_AXI_RREADY  <= 1'b0;

                    aw_done <= 1'b0;
                    w_done  <= 1'b0;

                    if (d_req) begin
                        active_is_d <= 1'b1;

                        if (d_we) begin
                            M_AXI_AWADDR  <= d_addr;
                            M_AXI_WDATA   <= d_wdata;
                            M_AXI_WSTRB   <= d_be;

                            M_AXI_AWVALID <= 1'b1;
                            M_AXI_WVALID  <= 1'b1;

                            state <= WRITE_ADDR_DATA;
                        end
                        else begin
                            M_AXI_ARADDR  <= d_addr;
                            M_AXI_ARVALID <= 1'b1;

                            state <= READ_ADDR;
                        end
                    end
                    else if (i_req) begin
                        active_is_d   <= 1'b0;
                        M_AXI_ARADDR  <= i_addr;
                        M_AXI_ARVALID <= 1'b1;

                        state <= READ_ADDR;
                    end
                end

                // READ ADDRESS CHANNEL
                READ_ADDR: begin
                    if (M_AXI_ARVALID && M_AXI_ARREADY) begin
                        M_AXI_ARVALID <= 1'b0;
                        M_AXI_RREADY  <= 1'b1;
                        state         <= READ_DATA;
                    end
                end

                // READ DATA CHANNEL
                READ_DATA: begin
                    if (M_AXI_RVALID && M_AXI_RREADY) begin
                        if (active_is_d) begin
                            d_rdata <= M_AXI_RDATA;
                            d_ready <= 1'b1;
                            state   <= WAIT_D_REQ_DROP;
                        end
                        else begin
                            i_rdata <= M_AXI_RDATA;
                            i_ready <= 1'b1;
                            state   <= IDLE;
                        end

                        M_AXI_RREADY <= 1'b0;
                    end
                end

                // WRITE ADDRESS + WRITE DATA CHANNELS
                WRITE_ADDR_DATA: begin
                    if (M_AXI_AWVALID && M_AXI_AWREADY) begin
                        M_AXI_AWVALID <= 1'b0;
                        aw_done       <= 1'b1;
                    end

                    if (M_AXI_WVALID && M_AXI_WREADY) begin
                        M_AXI_WVALID <= 1'b0;
                        w_done       <= 1'b1;
                    end

                    if ((aw_done || (M_AXI_AWVALID && M_AXI_AWREADY)) &&
                        (w_done  || (M_AXI_WVALID  && M_AXI_WREADY))) begin
                        M_AXI_BREADY <= 1'b1;
                        state        <= WRITE_RESP;
                    end
                end

                // WRITE RESPONSE CHANNEL
                WRITE_RESP: begin
                    if (M_AXI_BVALID && M_AXI_BREADY) begin
                        M_AXI_BREADY <= 1'b0;

                        // Assert and keep high in WAIT_D_REQ_DROP
                        d_ready <= 1'b1;
                        state   <= WAIT_D_REQ_DROP;
                    end
                end

                // WAIT UNTIL DCACHE DROPS D_REQ
                WAIT_D_REQ_DROP: begin
                    M_AXI_AWVALID <= 1'b0;
                    M_AXI_WVALID  <= 1'b0;
                    M_AXI_BREADY  <= 1'b0;
                    M_AXI_ARVALID <= 1'b0;
                    M_AXI_RREADY  <= 1'b0;

                    aw_done <= 1'b0;
                    w_done  <= 1'b0;

                    // Critical fix:
                    // Keep d_ready visible until dcache drops d_req.
                    d_ready <= 1'b1;

                    if (!d_req) begin
                        d_ready <= 1'b0;
                        state   <= IDLE;
                    end
                end

                default: begin
                    M_AXI_AWVALID <= 1'b0;
                    M_AXI_WVALID  <= 1'b0;
                    M_AXI_BREADY  <= 1'b0;
                    M_AXI_ARVALID <= 1'b0;
                    M_AXI_RREADY  <= 1'b0;

                    i_ready <= 1'b0;
                    d_ready <= 1'b0;

                    aw_done <= 1'b0;
                    w_done  <= 1'b0;

                    state <= IDLE;
                end

            endcase
        end
    end

endmodule