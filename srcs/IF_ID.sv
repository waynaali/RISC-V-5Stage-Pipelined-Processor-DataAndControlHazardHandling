`timescale 1ns / 1ps

module IF_ID(
    input logic clk,
    input logic reset,
    input logic en,
    input logic flush,
    
    // Inputs from IF stage
    input logic [31:0] InstrF,
    input logic [31:0] PCF,
    input logic [31:0] PCPlus4F,
    
    // Outputs to ID stage
    output logic [31:0] InstrD,
    output logic [31:0] PCD,
    output logic [31:0] PCPlus4D
);

always_ff @(posedge clk) begin
    if (reset | flush) begin
        // On reset or flush, clear all outputs to prevent wrong instruction execution
        InstrD <= 32'b0;
        PCD <= 32'b0;
        PCPlus4D <= 32'b0;
    end
    else if (en) begin
        // Normal operation: pass instruction and PC values from IF stage to ID stage
        InstrD <= InstrF;
        PCD <= PCF;
        PCPlus4D <= PCPlus4F; 
    end
    // If en is 0 and not reset/flush, hold previous values (pipeline stall)
end

endmodule
