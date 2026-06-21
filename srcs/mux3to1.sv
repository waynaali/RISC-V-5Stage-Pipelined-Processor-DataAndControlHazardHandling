`timescale 1ns / 1ps

module mux3to1(
    input  logic [31:0] d0,
    input  logic [31:0] d1,
    input  logic [31:0] d2,
    input  logic [1:0]  s,
    output logic [31:0] y
);

    assign y = s[1] ? d2 : (s[0] ? d1 : d0);

endmodule
