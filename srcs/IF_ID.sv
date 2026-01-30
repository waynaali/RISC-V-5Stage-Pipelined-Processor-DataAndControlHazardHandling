`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 11:30:01 AM
// Design Name: 
// Module Name: IF_ID
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IF_ID(input logic clk, reset,en, flush,
input logic [31:0] InstrF, PCF, PCPlus4F,
output logic [31:0] InstrD, PCD, PCPlus4D  );
always_ff @(posedge clk) begin
if (reset|flush) begin
InstrD<=32'b0;
PCD<=32'b0;
PCPlus4D<=32'b0;
end
else if (en) begin
InstrD<=InstrF;
PCD<=PCF;
PCPlus4D<=PCPlus4F; 
end
end
endmodule
