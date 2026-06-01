module icache (
    input  logic        clk,
    input  logic        rst,

    input  logic [31:0] cpu_addr,
    output logic [31:0] cpu_instr,
    output logic        hit,
    output logic        stall,

    output logic [31:0] mem_addr,
    input  logic [31:0] mem_rdata
);

    localparam CACHE_LINES = 16;
    localparam INDEX_BITS  = 4;
    localparam TAG_BITS    = 26;

    logic [31:0] data_array [0:CACHE_LINES-1];
    logic [TAG_BITS-1:0] tag_array [0:CACHE_LINES-1];
    logic valid_array [0:CACHE_LINES-1];

    logic [INDEX_BITS-1:0] index;
    logic [TAG_BITS-1:0] tag;

    assign index = cpu_addr[5:2];
    assign tag   = cpu_addr[31:6];

    assign mem_addr = cpu_addr;

    always_comb begin
        hit = valid_array[index] && (tag_array[index] == tag);

        // For first integration, no pipeline stall
        stall = 1'b0;

        // On hit: instruction from cache
        // On miss: instruction directly from instr_mem
        cpu_instr = hit ? data_array[index] : mem_rdata;
    end

    integer i;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < CACHE_LINES; i = i + 1) begin
                valid_array[i] <= 1'b0;
                tag_array[i]   <= '0;
                data_array[i]  <= 32'b0;
            end
        end
        else begin
            if (!hit) begin
                valid_array[index] <= 1'b1;
                tag_array[index]   <= tag;
                data_array[index]  <= mem_rdata;
            end
        end
    end

endmodule