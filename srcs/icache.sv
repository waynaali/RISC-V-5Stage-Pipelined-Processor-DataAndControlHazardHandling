module icache (
    input  logic        clk,
    input  logic        rst,

    input  logic        flush,      // PCSrcE from branch/JAL redirect

    input  logic [31:0] cpu_addr,
    output logic [31:0] cpu_instr,
    output logic        hit,
    output logic        stall,

    output logic        mem_req,
    output logic [31:0] mem_addr,
    input  logic [31:0] mem_rdata,
    input  logic        mem_ready
);

    localparam CACHE_LINES = 16;
    localparam INDEX_BITS  = 4;
    localparam TAG_BITS    = 26;

    logic [31:0] data_array [0:CACHE_LINES-1];
    logic [TAG_BITS-1:0] tag_array [0:CACHE_LINES-1];
    logic valid_array [0:CACHE_LINES-1];

    logic [INDEX_BITS-1:0] index;
    logic [TAG_BITS-1:0]   tag;

    logic [31:0] miss_addr;
    logic [INDEX_BITS-1:0] miss_index;
    logic [TAG_BITS-1:0]   miss_tag;

    typedef enum logic [1:0] {
        IDLE,
        MISS_WAIT,
        FLUSH_WAIT
    } state_t;

    state_t state;

    assign index = cpu_addr[5:2];
    assign tag   = cpu_addr[31:6];

    assign hit = valid_array[index] && (tag_array[index] == tag);

    always_comb begin
        cpu_instr = 32'b0;
        stall     = 1'b0;
        mem_req   = 1'b0;
        mem_addr  = cpu_addr;

        case (state)

            IDLE: begin
                if (flush) begin
                    cpu_instr = 32'b0;
                    stall     = 1'b1;
                    mem_req   = 1'b0;
                end
                else if (hit) begin
                    cpu_instr = data_array[index];
                    stall     = 1'b0;
                    mem_req   = 1'b0;
                end
                else begin
                    cpu_instr = 32'b0;
                    stall     = 1'b1;
                    mem_req   = 1'b1;
                    mem_addr  = cpu_addr;
                end
            end

            MISS_WAIT: begin
                cpu_instr = 32'b0;
                stall     = 1'b1;

                if (flush) begin
                    // Do not issue new request while redirect is happening
                    mem_req  = 1'b0;
                    mem_addr = miss_addr;
                end
                else begin
                    mem_req  = 1'b1;
                    mem_addr = miss_addr;
                end
            end

            FLUSH_WAIT: begin
                // Wait one old AXI response and ignore it
                cpu_instr = 32'b0;
                stall     = 1'b1;
                mem_req   = 1'b0;
                mem_addr  = miss_addr;
            end

            default: begin
                cpu_instr = 32'b0;
                stall     = 1'b1;
                mem_req   = 1'b0;
                mem_addr  = cpu_addr;
            end

        endcase
    end

    integer i;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            miss_addr  <= 32'b0;
            miss_index <= '0;
            miss_tag   <= '0;

            for (i = 0; i < CACHE_LINES; i = i + 1) begin
                valid_array[i] <= 1'b0;
                tag_array[i]   <= '0;
                data_array[i]  <= 32'b0;
            end
        end
        else begin
            case (state)

                IDLE: begin
                    if (!flush && !hit) begin
                        miss_addr  <= cpu_addr;
                        miss_index <= index;
                        miss_tag   <= tag;
                        state      <= MISS_WAIT;
                    end
                end

                MISS_WAIT: begin
                    if (flush) begin
                        // A branch/JAL redirect happened while old fetch was pending.
                        // Go wait for old response and discard it.
                        state <= FLUSH_WAIT;
                    end
                    else if (mem_ready) begin
                        valid_array[miss_index] <= 1'b1;
                        tag_array[miss_index]   <= miss_tag;
                        data_array[miss_index]  <= mem_rdata;
                        state <= IDLE;
                    end
                end

                FLUSH_WAIT: begin
                    if (mem_ready) begin
                        // Ignore old wrong-path response.
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