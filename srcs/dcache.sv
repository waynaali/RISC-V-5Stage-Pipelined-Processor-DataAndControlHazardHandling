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

    output logic        mem_req,
    output logic        mem_we,
    output logic [3:0]  mem_be,
    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,
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
    logic [1:0] offset;

    typedef enum logic [1:0] {
        IDLE,
        READ_MISS,
        WRITE_WAIT
    } state_t;

    state_t state;

    assign index  = cpu_addr[5:2];
    assign tag    = cpu_addr[31:6];
    assign offset = cpu_addr[1:0];

    assign hit = valid_array[index] && (tag_array[index] == tag);

    function automatic logic [31:0] load_extend(
        input logic [31:0] word,
        input logic [1:0]  off,
        input logic [2:0]  f3
    );
        logic [7:0] b;
        logic [15:0] h;
        begin
            case (off)
                2'b00: b = word[7:0];
                2'b01: b = word[15:8];
                2'b10: b = word[23:16];
                2'b11: b = word[31:24];
            endcase

            h = off[1] ? word[31:16] : word[15:0];

            case (f3)
                3'b000: load_extend = {{24{b[7]}}, b};   // LB
                3'b001: load_extend = {{16{h[15]}}, h};  // LH
                3'b010: load_extend = word;              // LW
                3'b100: load_extend = {24'b0, b};        // LBU
                3'b101: load_extend = {16'b0, h};        // LHU
                default: load_extend = word;
            endcase
        end
    endfunction

    function automatic logic [3:0] gen_be(
        input logic [1:0] off,
        input logic [2:0] f3
    );
        begin
            case (f3)
                3'b000: gen_be = 4'b0001 << off;             // SB
                3'b001: gen_be = off[1] ? 4'b1100 : 4'b0011; // SH
                3'b010: gen_be = 4'b1111;                    // SW
                default: gen_be = 4'b0000;
            endcase
        end
    endfunction

    function automatic logic [31:0] align_store_data(
        input logic [31:0] data,
        input logic [1:0]  off,
        input logic [2:0]  f3
    );
        begin
            case (f3)
                3'b000: align_store_data = {24'b0, data[7:0]}  << (off * 8);
                3'b001: align_store_data = {16'b0, data[15:0]} << (off[1] * 16);
                3'b010: align_store_data = data;
                default: align_store_data = data;
            endcase
        end
    endfunction

    function automatic logic [31:0] update_word(
        input logic [31:0] old_word,
        input logic [31:0] new_word,
        input logic [3:0]  be
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
        cpu_rdata = 32'b0;

        stall     = 1'b0;
        mem_req   = 1'b0;
        mem_we    = 1'b0;
        mem_be    = 4'b0000;
        mem_addr  = {cpu_addr[31:2], 2'b00};
        mem_wdata = 32'b0;

        case (state)

            IDLE: begin
                if (mem_read) begin
                    if (hit) begin
                        cpu_rdata = load_extend(data_array[index], offset, funct3);
                        stall     = 1'b0;
                    end else begin
                        mem_req = 1'b1;
                        mem_we  = 1'b0;
                        stall   = 1'b1;
                    end
                end

                else if (mem_write) begin
                    mem_req   = 1'b1;
                    mem_we    = 1'b1;
                    mem_be    = gen_be(offset, funct3);
                    mem_wdata = align_store_data(cpu_wdata, offset, funct3);

                    // Fix: with ready memory, store should complete immediately
                    stall = ~mem_ready;
                end
            end

            READ_MISS: begin
                mem_req = 1'b1;
                mem_we  = 1'b0;
                stall   = 1'b1;

                if (mem_ready) begin
                    cpu_rdata = load_extend(mem_rdata, offset, funct3);
                end
            end

            WRITE_WAIT: begin
                mem_req   = 1'b1;
                mem_we    = 1'b1;
                mem_be    = gen_be(offset, funct3);
                mem_addr  = {cpu_addr[31:2], 2'b00};
                mem_wdata = align_store_data(cpu_wdata, offset, funct3);

                stall = ~mem_ready;
            end

            default: begin
                stall = 1'b0;
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
                    if (mem_read && !hit) begin
                        state <= READ_MISS;
                    end

                    else if (mem_write) begin
                        valid_array[index] <= 1'b1;
                        tag_array[index]   <= tag;
                        data_array[index]  <= update_word(
                            hit ? data_array[index] : mem_rdata,
                            align_store_data(cpu_wdata, offset, funct3),
                            gen_be(offset, funct3)
                        );

                        if (!mem_ready)
                            state <= WRITE_WAIT;
                        else
                            state <= IDLE;
                    end
                end

                READ_MISS: begin
                    if (mem_ready) begin
                        valid_array[index] <= 1'b1;
                        tag_array[index]   <= tag;
                        data_array[index]  <= mem_rdata;
                        state              <= IDLE;
                    end
                end

                WRITE_WAIT: begin
                    if (mem_ready) begin
                        valid_array[index] <= 1'b1;
                        tag_array[index]   <= tag;
                        data_array[index]  <= update_word(
                            hit ? data_array[index] : mem_rdata,
                            align_store_data(cpu_wdata, offset, funct3),
                            gen_be(offset, funct3)
                        );

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