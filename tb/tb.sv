`timescale 1ns / 1ps

module tb_risc;

    logic clk;
    logic reset;

    integer sw_count;
    integer sb_count;
    integer sh_count;
    integer axi_read_count;
    integer axi_write_count;

    rvhazard top(
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;

        #40;
        reset = 0;

        #5000;

        $display("\n========== FINAL VERIFICATION SUMMARY ==========");
        $display("AXI Reads  = %0d", axi_read_count);
        $display("AXI Writes = %0d", axi_write_count);
        $display("SW Count   = %0d", sw_count);
        $display("SB Count   = %0d", sb_count);
        $display("SH Count   = %0d", sh_count);

        if (axi_read_count > 0)  $display("PASS: AXI read channel active");
        else                     $display("FAIL: No AXI read detected");

        if (axi_write_count > 0) $display("PASS: AXI write channel active");
        else                     $display("FAIL: No AXI write detected");

        if (sw_count > 0)        $display("PASS: SW detected");
        else                     $display("FAIL: SW not detected");

        if (sb_count > 0)        $display("PASS: SB detected");
        else                     $display("FAIL: SB not detected");

        if (sh_count > 0)        $display("PASS: SH detected");
        else                     $display("FAIL: SH not detected");

        $display("Final PCF = %h", top.PCF);
        $display("===============================================\n");

        $finish;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            sw_count        <= 0;
            sb_count        <= 0;
            sh_count        <= 0;
            axi_read_count  <= 0;
            axi_write_count <= 0;
        end
        else begin
            if (top.axi_arvalid && top.axi_arready) begin
                axi_read_count <= axi_read_count + 1;
            end

            if (top.axi_awvalid && top.axi_awready &&
                top.axi_wvalid  && top.axi_wready) begin

                axi_write_count <= axi_write_count + 1;

                case (top.axi_wstrb)
                    4'b1111: sw_count <= sw_count + 1;
                    4'b0001,
                    4'b0010,
                    4'b0100,
                    4'b1000: sb_count <= sb_count + 1;
                    4'b0011,
                    4'b1100: sh_count <= sh_count + 1;
                    default: ;
                endcase
            end
        end
    end

    initial begin
        $display("Time\tPCF\tInstrF\tIReq\tIReady\tDReq\tDReady\tARV\tARR\tARAddr\tRVal\tRReady\tRData\tAWV\tAWR\tWV\tWR\tWData\tWSTRB\tBVal\tBReady");

        $monitor("%0t\t%h\t%h\t%b\t%b\t%b\t%b\t%b\t%b\t%h\t%b\t%b\t%h\t%b\t%b\t%b\t%b\t%h\t%b\t%b\t%b",
            $time,
            top.PCF,
            top.InstrF,
            top.icache_mem_req,
            top.icache_mem_ready,
            top.dcache_mem_req,
            top.dcache_mem_ready,
            top.axi_arvalid,
            top.axi_arready,
            top.axi_araddr,
            top.axi_rvalid,
            top.axi_rready,
            top.axi_rdata,
            top.axi_awvalid,
            top.axi_awready,
            top.axi_wvalid,
            top.axi_wready,
            top.axi_wdata,
            top.axi_wstrb,
            top.axi_bvalid,
            top.axi_bready
        );
    end

endmodule