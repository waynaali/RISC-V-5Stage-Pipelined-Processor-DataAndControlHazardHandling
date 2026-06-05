module cache_axi_lite_master (
    input  logic        clk,
    input  logic        reset,

    // I-Cache side
    input  logic        i_req,
    input  logic [31:0] i_addr,
    output logic [31:0] i_rdata,
    output logic        i_ready,

    // D-Cache side
    input  logic        d_req,
    input  logic        d_we,
    input  logic [3:0]  d_be,
    input  logic [31:0] d_addr,
    input  logic [31:0] d_wdata,
    output logic [31:0] d_rdata,
    output logic        d_ready,

    // AXI-Lite Master Interface
    output logic [31:0] M_AXI_AWADDR,
    output logic        M_AXI_AWVALID,
    input  logic        M_AXI_AWREADY,

    output logic [31:0] M_AXI_WDATA,
    output logic [3:0]  M_AXI_WSTRB,
    output logic        M_AXI_WVALID,
    input  logic        M_AXI_WREADY,

    input  logic [1:0]  M_AXI_BRESP,
    input  logic        M_AXI_BVALID,
    output logic        M_AXI_BREADY,

    output logic [31:0] M_AXI_ARADDR,
    output logic        M_AXI_ARVALID,
    input  logic        M_AXI_ARREADY,

    input  logic [31:0] M_AXI_RDATA,
    input  logic [1:0]  M_AXI_RRESP,
    input  logic        M_AXI_RVALID,
    output logic        M_AXI_RREADY
);

    typedef enum logic [2:0] {
        IDLE,
        READ_ADDR,
        READ_DATA,
        WRITE_ADDR_DATA,
        WRITE_RESP,
        WAIT_REQ_DROP
    } state_t;

    state_t state;

    logic        active_is_d;
    logic        active_we;
    logic [31:0] active_addr;
    logic [31:0] active_wdata;
    logic [3:0]  active_be;

    logic [31:0] rdata_hold;

    always_comb begin
        i_ready = 1'b0;
        d_ready = 1'b0;
        i_rdata = 32'b0;
        d_rdata = 32'b0;

        M_AXI_AWADDR  = active_addr;
        M_AXI_AWVALID = 1'b0;

        M_AXI_WDATA   = active_wdata;
        M_AXI_WSTRB   = active_be;
        M_AXI_WVALID  = 1'b0;

        M_AXI_BREADY  = 1'b0;

        M_AXI_ARADDR  = active_addr;
        M_AXI_ARVALID = 1'b0;

        M_AXI_RREADY  = 1'b0;

        case (state)

            READ_ADDR: begin
                M_AXI_ARVALID = 1'b1;
            end

            READ_DATA: begin
                M_AXI_RREADY = 1'b1;

                if (M_AXI_RVALID) begin
                    if (active_is_d) begin
                        d_ready = 1'b1;
                        d_rdata = M_AXI_RDATA;
                    end else begin
                        i_ready = 1'b1;
                        i_rdata = M_AXI_RDATA;
                    end
                end
            end

            WRITE_ADDR_DATA: begin
                M_AXI_AWVALID = 1'b1;
                M_AXI_WVALID  = 1'b1;
            end

            WRITE_RESP: begin
                M_AXI_BREADY = 1'b1;

                if (M_AXI_BVALID) begin
                    d_ready = 1'b1;
                end
            end

            default: begin
            end
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            active_is_d  <= 1'b0;
            active_we    <= 1'b0;
            active_addr  <= 32'b0;
            active_wdata <= 32'b0;
            active_be    <= 4'b0000;
            rdata_hold   <= 32'b0;
        end else begin
            case (state)

                IDLE: begin
                    // D-cache priority
                    if (d_req) begin
                        active_is_d  <= 1'b1;
                        active_we    <= d_we;
                        active_addr  <= d_addr;
                        active_wdata <= d_wdata;
                        active_be    <= d_be;

                        if (d_we)
                            state <= WRITE_ADDR_DATA;
                        else
                            state <= READ_ADDR;
                    end
                    else if (i_req) begin
                        active_is_d  <= 1'b0;
                        active_we    <= 1'b0;
                        active_addr  <= i_addr;
                        active_wdata <= 32'b0;
                        active_be    <= 4'b1111;

                        state <= READ_ADDR;
                    end
                end

                READ_ADDR: begin
                    if (M_AXI_ARREADY)
                        state <= READ_DATA;
                end

                READ_DATA: begin
                    if (M_AXI_RVALID) begin
                        rdata_hold <= M_AXI_RDATA;
                        state      <= WAIT_REQ_DROP;
                    end
                end

                WRITE_ADDR_DATA: begin
                    if (M_AXI_AWREADY && M_AXI_WREADY)
                        state <= WRITE_RESP;
                end

                WRITE_RESP: begin
                    if (M_AXI_BVALID)
                        state <= WAIT_REQ_DROP;
                end

                WAIT_REQ_DROP: begin
                    if (active_is_d) begin
                        if (!d_req)
                            state <= IDLE;
                    end else begin
                        if (!i_req)
                            state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule