module IE_IM(
    input  logic        clk,
    input  logic        reset,
    input  logic        en,

    input  logic [31:0] ALUResultE,
    input  logic [31:0] RD2E,
    input  logic        RegWriteE,
    input  logic        MemWriteE,
    input  logic [1:0]  ResultSrcE,
    input  logic [4:0]  rdE,
    input  logic [31:0] PCPlus4E,
    input  logic [2:0]  funct3E,

    output logic [31:0] ALUResultM,
    output logic [31:0] RD2M,
    output logic        RegWriteM,
    output logic        MemWriteM,
    output logic [1:0]  ResultSrcM,
    output logic [4:0]  rdM,
    output logic [31:0] PCPlus4M,
    output logic [2:0]  funct3M
);

    always_ff @(posedge clk) begin
        if (reset) begin
            ALUResultM <= 32'b0;
            RD2M       <= 32'b0;
            RegWriteM  <= 1'b0;
            MemWriteM  <= 1'b0;
            ResultSrcM <= 2'b0;
            rdM        <= 5'b0;
            PCPlus4M   <= 32'b0;
            funct3M    <= 3'b0;
        end
        else if (en) begin
            ALUResultM <= ALUResultE;
            RD2M       <= RD2E;
            RegWriteM  <= RegWriteE;
            MemWriteM  <= MemWriteE;
            ResultSrcM <= ResultSrcE;
            rdM        <= rdE;
            PCPlus4M   <= PCPlus4E;
            funct3M    <= funct3E;
        end
    end

endmodule