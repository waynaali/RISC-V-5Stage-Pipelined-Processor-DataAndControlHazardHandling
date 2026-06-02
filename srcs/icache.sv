module icache (
    input  logic        clk,
    input  logic        rst,

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
    logic [TAG_BITS-1:0] tag;

    typedef enum logic [1:0] {
        IDLE,
        MISS_WAIT
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
                if (hit) begin
                    cpu_instr = data_array[index];
                    stall     = 1'b0;
                end else begin
                    cpu_instr = 32'b0;
                    stall     = 1'b1;
                    mem_req   = 1'b1;
                end
            end

            MISS_WAIT: begin
                cpu_instr = 32'b0;
                stall     = 1'b1;
                mem_req   = 1'b1;
            end

            default: begin
                cpu_instr = 32'b0;
                stall     = 1'b1;
                mem_req   = 1'b0;
            end
        endcase
    end

    integer i;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            for (i = 0; i < CACHE_LINES; i = i + 1) begin
                valid_array[i] <= 1'b0;
                tag_array[i]   <= '0;
                data_array[i]  <= 32'b0;
            end
        end else begin
            case (state)
                IDLE: begin
                    if (!hit) begin
                        state <= MISS_WAIT;
                    end
                end

                MISS_WAIT: begin
                    if (mem_ready) begin
                        valid_array[index] <= 1'b1;
                        tag_array[index]   <= tag;
                        data_array[index]  <= mem_rdata;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule