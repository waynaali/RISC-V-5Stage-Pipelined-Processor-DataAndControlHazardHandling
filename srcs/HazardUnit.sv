`timescale 1ns / 1ps
module HazardUnit(
    input  logic [4:0] Rs1D,
    input  logic [4:0] Rs2D,
    input  logic [4:0] RdE,
    input  logic  PCSrcE, ResultSrcE0,   // 1 if load in EX stage
    output logic StallF,
    output logic StallD,
    output logic FlushE,
    output logic FlushD
);

logic lwStall;

assign lwStall=ResultSrcE0&&((Rs1D==RdE)||(Rs2D==RdE))&&(RdE!=0);
assign FlushE=lwStall|PCSrcE;
assign FlushD=PCSrcE;
assign StallF=lwStall;
assign StallD=lwStall;

endmodule