`timescale 1ns / 1ps

module tb_risc;

    logic clk;
    logic reset;

    rvhazard top(
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;

        #20 reset = 0;

        #2000 $finish;
    end

    // Waveform dump for GTKWave / XSim
    initial begin
        $dumpfile("icache_wave.vcd");
        $dumpvars(0, tb_risc);
    end

    // I-Cache verification monitor
    initial begin
        $display("Time\tPCF\t\tInstrF\t\tMemAddr\t\tMemData\t\tHit\tStall");
        $monitor("%0t\t%h\t%h\t%h\t%h\t%b\t%b",
                 $time,
                 top.PCF,
                 top.InstrF,
                 top.icache_mem_addr,
                 top.icache_mem_rdata,
                 top.icache_hit,
                 top.icache_stall);
    end

endmodule