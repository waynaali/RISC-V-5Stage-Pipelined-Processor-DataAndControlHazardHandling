`timescale 1ns / 1ps

module program_counter(
    input  logic        clk,
    input  logic        reset,
    input  logic        en,
    input  logic [31:0] PCNext,
    output logic [31:0] PC
);

always_ff @(posedge clk or posedge reset) begin  // Async reset
    if (reset) begin
        PC <= 32'h00000000;
    end
    else if (en) begin
        PC <= PCNext;
    end
end

endmodule
