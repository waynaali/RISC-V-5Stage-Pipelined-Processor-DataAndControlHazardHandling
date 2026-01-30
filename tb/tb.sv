`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 04:04:23 PM
// Design Name: 
// Module Name: testbench (tb_risc)
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   Testbench for the pipelined RISC-V processor (rvhazard). 
//   Generates clock and reset signals and runs the simulation for a fixed time.
//   Used to verify correct pipeline operation, including forwarding, hazards, 
//   and ALU/memory functionality.
//
// Dependencies: rvhazard module
//
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module tb_risc;

    // Testbench signals
    logic clk;    // Clock signal
    logic reset;  // Reset signal

    // Instantiate the top-level RISC-V pipeline module
    rvhazard top(
        .clk(clk),
        .reset(reset)
    );

    /////////////////////////////
    // Clock Generation
    /////////////////////////////
    // 10 ns period clock (100 MHz)
    always #5 clk = ~clk;

    /////////////////////////////
    // Test Sequence
    /////////////////////////////
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;

        // Keep reset high for 20 ns to initialize the processor
        #20 reset = 0;

        // Run simulation for 2000 ns (~200 clock cycles)
        #2000 $finish;
    end

endmodule

