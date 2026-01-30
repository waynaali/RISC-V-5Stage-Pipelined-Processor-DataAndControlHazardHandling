`timescale 1ns/1ps
module program_counter(
    input  logic        clk, reset,en,
    input  logic [31:0] PCNext,
    output logic [31:0] PC
);

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        PC <= 32'h00000000;
 end
    else if (en) begin
        PC <= PCNext;
end
end
endmodule