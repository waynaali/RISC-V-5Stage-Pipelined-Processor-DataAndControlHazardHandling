`timescale 1ns / 1ps

module tb_risc;

    logic clk;
    logic reset;

    rvhazard top(
        .clk(clk),
        .reset(reset)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;

        #30;
        reset = 0;

        #3000;
        $finish;
    end

    // Console verification monitor
    initial begin
        $display("Time\tPCF\t\tInstrF\t\tIHit\tIStall\tIReq\tDAddr\t\tWData\t\tRData\t\tDHit\tDStall\tDReq\tDWe\tDBe");
        $monitor("%0t\t%h\t%h\t%b\t%b\t%b\t%h\t%h\t%h\t%b\t%b\t%b\t%b\t%b",
                 $time,
                 top.PCF,
                 top.InstrF,
                 top.icache_hit,
                 top.icache_stall,
                 top.icache_mem_req,
                 top.ALUResultM,
                 top.RD2M,
                 top.ReadDataM,
                 top.dcache_hit,
                 top.dcache_stall,
                 top.dcache_mem_req,
                 top.dcache_mem_we,
                 top.dcache_mem_be);
    end

endmodule