module dcache (
    input  logic        clk,
    input  logic        rst,

    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [2:0]  funct3,
    input  logic [31:0] cpu_addr,
    input  logic [31:0] cpu_wdata,
    output logic [31:0] cpu_rdata,

    output logic        hit,
    output logic        stall,

    output logic        mem_we,
    output logic [3:0]  mem_be,
    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,
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
    logic [1:0] byte_offset;

    logic [31:0] selected_word;
    logic [31:0] store_aligned;
    logic [3:0]  byte_enable;

    assign index       = cpu_addr[5:2];
    assign tag         = cpu_addr[31:6];
    assign byte_offset = cpu_addr[1:0];

    assign hit = valid_array[index] && (tag_array[index] == tag);

    assign selected_word = hit ? data_array[index] : mem_rdata;

    function automatic logic [31:0] load_extend(
        input logic [31:0] word,
        input logic [1:0] offset,
        input logic [2:0] f3
    );
        logic [7:0] b;
        logic [15:0] h;
        begin
            case (offset)
                2'b00: b = word[7:0];
                2'b01: b = word[15:8];
                2'b10: b = word[23:16];
                2'b11: b = word[31:24];
            endcase

            h = offset[1] ? word[31:16] : word[15:0];

            case (f3)
                3'b000: load_extend = {{24{b[7]}}, b};     // LB
                3'b001: load_extend = {{16{h[15]}}, h};    // LH
                3'b010: load_extend = word;                // LW
                3'b100: load_extend = {24'b0, b};          // LBU
                3'b101: load_extend = {16'b0, h};          // LHU
                default: load_extend = word;
            endcase
        end
    endfunction

    function automatic logic [3:0] gen_be(
        input logic [1:0] offset,
        input logic [2:0] f3
    );
        begin
            case (f3)
                3'b000: gen_be = 4'b0001 << offset;             // SB
                3'b001: gen_be = offset[1] ? 4'b1100 : 4'b0011; // SH
                3'b010: gen_be = 4'b1111;                       // SW
                default: gen_be = 4'b0000;
            endcase
        end
    endfunction

    function automatic logic [31:0] align_store_data(
        input logic [31:0] data,
        input logic [1:0] offset,
        input logic [2:0] f3
    );
        begin
            case (f3)
                3'b000: align_store_data = (data[7:0]  << (offset * 8));
                3'b001: align_store_data = (data[15:0] << (offset[1] * 16));
                3'b010: align_store_data = data;
                default: align_store_data = data;
            endcase
        end
    endfunction

    function automatic logic [31:0] update_word(
        input logic [31:0] old_word,
        input logic [31:0] new_word,
        input logic [3:0] be
    );
        begin
            update_word = old_word;
            if (be[0]) update_word[7:0]   = new_word[7:0];
            if (be[1]) update_word[15:8]  = new_word[15:8];
            if (be[2]) update_word[23:16] = new_word[23:16];
            if (be[3]) update_word[31:24] = new_word[31:24];
        end
    endfunction

    always_comb begin
        stall        = 1'b0;
        cpu_rdata    = load_extend(selected_word, byte_offset, funct3);

        mem_we       = 1'b0;
        mem_be       = 4'b0000;
        mem_addr     = {cpu_addr[31:2], 2'b00};
        mem_wdata    = 32'b0;

        byte_enable   = gen_be(byte_offset, funct3);
        store_aligned = align_store_data(cpu_wdata, byte_offset, funct3);

        if (mem_write) begin
            mem_we    = 1'b1;
            mem_be    = byte_enable;
            mem_wdata = store_aligned;
        end
    end

    integer i;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < CACHE_LINES; i = i + 1) begin
                valid_array[i] <= 1'b0;
                tag_array[i]   <= '0;
                data_array[i]  <= 32'b0;
            end
        end else begin
            if (mem_read && !hit) begin
                valid_array[index] <= 1'b1;
                tag_array[index]   <= tag;
                data_array[index]  <= mem_rdata;
            end

            if (mem_write) begin
                valid_array[index] <= 1'b1;
                tag_array[index]   <= tag;
                data_array[index]  <= update_word(selected_word, store_aligned, byte_enable);
            end
        end
    end

endmodule