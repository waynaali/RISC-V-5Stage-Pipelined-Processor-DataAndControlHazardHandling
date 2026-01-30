`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 08:42:09 AM
// Design Name: 
// Module Name: hazard_unt
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


module forwarding_unit(input logic [4:0] Rs2E, Rs1E, RdM,RdW,
input logic RegWriteM, RegWriteW,
output logic [1:0] ForwardAE, ForwardBE);
always_comb begin
   
if ((Rs1E==RdM)&&(RegWriteM)&&(Rs1E!=0)) begin
            ForwardAE=2'b10;
            end
else if ((Rs1E==RdW) && (RegWriteW)&&(Rs1E!=0)) begin
          ForwardAE=2'b01;
          end
          else begin
           ForwardAE = 2'b00;
           end
          if ((Rs2E==RdM)&&(RegWriteM)&&(Rs2E!=0)) begin
                      ForwardBE=2'b10;
                      end
          else if ((Rs2E==RdW) && (RegWriteW)&&(Rs2E!=0)) begin
                    ForwardBE=2'b01;
               end
else begin
 ForwardBE = 2'b00;
 end
 end
endmodule
