`timescale 1ns / 1ps

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

    logic [31:0]         data_array  [0:CACHE_LINES-1];
    logic [TAG_BITS-1:0] tag_array   [0:CACHE_LINES-1];
    logic                valid_array [0:CACHE_LINES-1];

    logic [INDEX_BITS-1:0] index;
    logic [TAG_BITS-1:0]   tag;
    logic [1:0]            offset;

    logic [31:0] saved_addr;
    logic [31:0] saved_aligned_wdata;
    logic [2:0]  saved_funct3;
    logic [3:0]  saved_be;
    logic [INDEX_BITS-1:0] saved_index;
    logic [TAG_BITS-1:0]   saved_tag;
    logic [1:0]            saved_offset;

    logic [31:0] load_data_reg;

    logic store_issued;
    logic same_store_done;

    logic load_issued;
    logic same_load_done;

    typedef enum logic [2:0] {
        IDLE,
        READ_MISS,
        COMPLETE_READ,
        WRITE_WAIT,
        COMPLETE_WRITE
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
        logic [7:0]  b;
        logic [15:0] h;
        begin
            case (off)
                2'b00: b = word[7:0];
                2'b01: b = word[15:8];
                2'b10: b = word[23:16];
                2'b11: b = word[31:24];
                default: b = word[7:0];
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
                3'b000: begin
                    case (off)
                        2'b00: gen_be = 4'b0001;
                        2'b01: gen_be = 4'b0010;
                        2'b10: gen_be = 4'b0100;
                        2'b11: gen_be = 4'b1000;
                        default: gen_be = 4'b0001;
                    endcase
                end

                3'b001: gen_be = off[1] ? 4'b1100 : 4'b0011;
                3'b010: gen_be = 4'b1111;
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
                3'b000: begin
                    case (off)
                        2'b00: align_store_data = {24'b0, data[7:0]};
                        2'b01: align_store_data = {16'b0, data[7:0], 8'b0};
                        2'b10: align_store_data = {8'b0, data[7:0], 16'b0};
                        2'b11: align_store_data = {data[7:0], 24'b0};
                        default: align_store_data = {24'b0, data[7:0]};
                    endcase
                end

                3'b001: align_store_data = off[1] ? {data[15:0], 16'b0} :
                                                     {16'b0, data[15:0]};
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
        same_store_done =
            store_issued &&
            mem_write &&
            (saved_addr == {cpu_addr[31:2], 2'b00}) &&
            (saved_be == gen_be(offset, funct3)) &&
            (saved_aligned_wdata == align_store_data(cpu_wdata, offset, funct3));

        same_load_done =
            load_issued &&
            mem_read &&
            (saved_addr == {cpu_addr[31:2], 2'b00}) &&
            (saved_funct3 == funct3) &&
            (saved_offset == offset);
    end

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
                    if (same_load_done) begin
                        cpu_rdata = load_data_reg;
                        stall     = 1'b0;
                    end
                    else if (hit) begin
                        stall = 1'b1;
                    end
                    else begin
                        mem_req  = 1'b1;
                        mem_we   = 1'b0;
                        mem_addr = {cpu_addr[31:2], 2'b00};
                        stall    = 1'b1;
                    end
                end

                else if (mem_write) begin
                    if (same_store_done) begin
                        stall = 1'b0;
                    end
                    else begin
                        mem_req   = 1'b1;
                        mem_we    = 1'b1;
                        mem_be    = gen_be(offset, funct3);
                        mem_addr  = {cpu_addr[31:2], 2'b00};
                        mem_wdata = align_store_data(cpu_wdata, offset, funct3);
                        stall     = 1'b1;
                    end
                end
            end

            READ_MISS: begin
                mem_req  = 1'b1;
                mem_we   = 1'b0;
                mem_addr = saved_addr;
                stall    = 1'b1;
            end

            COMPLETE_READ: begin
                cpu_rdata = load_data_reg;
                stall     = 1'b0;
            end

            WRITE_WAIT: begin
                mem_req   = 1'b1;
                mem_we    = 1'b1;
                mem_be    = saved_be;
                mem_addr  = saved_addr;
                mem_wdata = saved_aligned_wdata;
                stall     = 1'b1;
            end

            COMPLETE_WRITE: begin
                stall = 1'b0;
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

            saved_addr          <= 32'b0;
            saved_aligned_wdata <= 32'b0;
            saved_funct3        <= 3'b0;
            saved_be            <= 4'b0;
            saved_index         <= '0;
            saved_tag           <= '0;
            saved_offset        <= 2'b0;
            load_data_reg       <= 32'b0;

            store_issued <= 1'b0;
            load_issued  <= 1'b0;

            for (i = 0; i < CACHE_LINES; i = i + 1) begin
                valid_array[i] <= 1'b0;
                tag_array[i]   <= '0;
                data_array[i]  <= 32'b0;
            end
        end
        else begin
            if (!mem_write) begin
                store_issued <= 1'b0;
            end

            if (!mem_read) begin
                load_issued <= 1'b0;
            end

            case (state)

                IDLE: begin
                    if (mem_read && !same_load_done) begin
                        saved_addr   <= {cpu_addr[31:2], 2'b00};
                        saved_funct3 <= funct3;
                        saved_index  <= index;
                        saved_tag    <= tag;
                        saved_offset <= offset;

                        if (hit) begin
                            load_data_reg <= load_extend(data_array[index], offset, funct3);
                            load_issued  <= 1'b1;
                            state        <= COMPLETE_READ;
                        end
                        else begin
                            state <= READ_MISS;
                        end
                    end

                    else if (mem_write && !same_store_done) begin
                        saved_addr          <= {cpu_addr[31:2], 2'b00};
                        saved_funct3        <= funct3;
                        saved_be            <= gen_be(offset, funct3);
                        saved_aligned_wdata <= align_store_data(cpu_wdata, offset, funct3);
                        saved_index         <= index;
                        saved_tag           <= tag;
                        saved_offset        <= offset;

                        valid_array[index] <= 1'b1;
                        tag_array[index]   <= tag;
                        data_array[index]  <= update_word(
                            hit ? data_array[index] : 32'b0,
                            align_store_data(cpu_wdata, offset, funct3),
                            gen_be(offset, funct3)
                        );

                        if (mem_ready) begin
                            store_issued <= 1'b1;
                            state        <= COMPLETE_WRITE;
                        end
                        else begin
                            state <= WRITE_WAIT;
                        end
                    end
                end

                READ_MISS: begin
                    if (mem_ready) begin
                        valid_array[saved_index] <= 1'b1;
                        tag_array[saved_index]   <= saved_tag;
                        data_array[saved_index]  <= mem_rdata;

                        load_data_reg <= load_extend(mem_rdata, saved_offset, saved_funct3);
                        load_issued   <= 1'b1;
                        state         <= COMPLETE_READ;
                    end
                end

                COMPLETE_READ: begin
                    state <= IDLE;
                end

                WRITE_WAIT: begin
                    if (mem_ready) begin
                        valid_array[saved_index] <= 1'b1;
                        tag_array[saved_index]   <= saved_tag;
                        data_array[saved_index]  <= update_word(
                            (valid_array[saved_index] && tag_array[saved_index] == saved_tag) ?
                            data_array[saved_index] : 32'b0,
                            saved_aligned_wdata,
                            saved_be
                        );

                        store_issued <= 1'b1;
                        state        <= COMPLETE_WRITE;
                    end
                end

                COMPLETE_WRITE: begin
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule