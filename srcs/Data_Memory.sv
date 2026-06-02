module data_mem(
    input  logic        clk,
    input  logic        we,
    input  logic [3:0]  be,
    input  logic [31:0] A,
    input  logic [31:0] WD,
    output logic [31:0] ReadData
);

    logic [31:0] RAM [0:255];

    assign ReadData = RAM[A[31:2]];

    always_ff @(posedge clk) begin
        if (we) begin
            if (be[0]) RAM[A[31:2]][7:0]   <= WD[7:0];
            if (be[1]) RAM[A[31:2]][15:8]  <= WD[15:8];
            if (be[2]) RAM[A[31:2]][23:16] <= WD[23:16];
            if (be[3]) RAM[A[31:2]][31:24] <= WD[31:24];
        end
    end

endmodule