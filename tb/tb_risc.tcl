# ============================================================
# Vivado XSim TCL Script
# RV32I Pipeline + Cache + AXI4 Verification
# ============================================================

restart
catch { remove_wave -all }

# 1. Top-Level Testbench Signals
add_wave /tb_risc/clk
add_wave /tb_risc/reset

# 2. Program Counter and Instruction Flow
add_wave /tb_risc/dut/PCF
add_wave /tb_risc/dut/InstrF
add_wave /tb_risc/dut/PCD
add_wave /tb_risc/dut/InstrD
add_wave /tb_risc/dut/PCE
add_wave /tb_risc/dut/PCTargetE
add_wave /tb_risc/dut/PCSrcE

# 3. Pipeline Result / Writeback
add_wave /tb_risc/dut/ALUResultE
add_wave /tb_risc/dut/ALUResultM
add_wave /tb_risc/dut/ALUResultW
add_wave /tb_risc/dut/ReadDataM
add_wave /tb_risc/dut/ReadDataW
add_wave /tb_risc/dut/ResultW
add_wave /tb_risc/dut/rdW
add_wave /tb_risc/dut/RegWriteW

# 4. Register File Write Port
add_wave /tb_risc/dut/register_file_inst/A3
add_wave /tb_risc/dut/register_file_inst/wd3
add_wave /tb_risc/dut/register_file_inst/we
add_wave /tb_risc/dut/register_file_inst/A1
add_wave /tb_risc/dut/register_file_inst/A2
add_wave /tb_risc/dut/register_file_inst/rd1
add_wave /tb_risc/dut/register_file_inst/rd2

# 5. Hazard / Stall / Flush
add_wave /tb_risc/dut/StallF
add_wave /tb_risc/dut/StallD
add_wave /tb_risc/dut/FlushD
add_wave /tb_risc/dut/FlushE
add_wave /tb_risc/dut/ForwardAE
add_wave /tb_risc/dut/ForwardBE

# 6. Cache Interfaces
add_wave /tb_risc/dut/icache_mem_req
add_wave /tb_risc/dut/icache_mem_ready
add_wave /tb_risc/dut/icache_mem_addr
add_wave /tb_risc/dut/icache_mem_rdata

add_wave /tb_risc/dut/dcache_mem_req
add_wave /tb_risc/dut/dcache_mem_ready
add_wave /tb_risc/dut/dcache_mem_we
add_wave /tb_risc/dut/dcache_mem_be
add_wave /tb_risc/dut/dcache_mem_addr
add_wave /tb_risc/dut/dcache_mem_wdata
add_wave /tb_risc/dut/dcache_mem_rdata

# 7. AXI4 Read Channel
add_wave /tb_risc/dut/axi_araddr
add_wave /tb_risc/dut/axi_arlen
add_wave /tb_risc/dut/axi_arsize
add_wave /tb_risc/dut/axi_arburst
add_wave /tb_risc/dut/axi_arvalid
add_wave /tb_risc/dut/axi_arready
add_wave /tb_risc/dut/axi_rdata
add_wave /tb_risc/dut/axi_rlast
add_wave /tb_risc/dut/axi_rvalid
add_wave /tb_risc/dut/axi_rready

# 8. AXI4 Write Channel
add_wave /tb_risc/dut/axi_awaddr
add_wave /tb_risc/dut/axi_awlen
add_wave /tb_risc/dut/axi_awsize
add_wave /tb_risc/dut/axi_awburst
add_wave /tb_risc/dut/axi_awvalid
add_wave /tb_risc/dut/axi_awready
add_wave /tb_risc/dut/axi_wdata
add_wave /tb_risc/dut/axi_wstrb
add_wave /tb_risc/dut/axi_wlast
add_wave /tb_risc/dut/axi_wvalid
add_wave /tb_risc/dut/axi_wready
add_wave /tb_risc/dut/axi_bvalid
add_wave /tb_risc/dut/axi_bready

# 9. Scoreboard / Verification Results
add_wave /tb_risc/axi_read_count
add_wave /tb_risc/axi_write_count
add_wave /tb_risc/axi4_error_count

add_wave /tb_risc/sw_100_seen
add_wave /tb_risc/sw_104_seen
add_wave /tb_risc/sb_108_seen
add_wave /tb_risc/sh_10c_seen

add_wave /tb_risc/r4_ok
add_wave /tb_risc/r5_ok
add_wave /tb_risc/r6_ok
add_wave /tb_risc/r7_ok
add_wave /tb_risc/r8_ok
add_wave /tb_risc/r9_ok
add_wave /tb_risc/r11_ok
add_wave /tb_risc/r12_ok
add_wave /tb_risc/r13_ok
add_wave /tb_risc/r14_ok
add_wave /tb_risc/r15_ok
add_wave /tb_risc/r16_ok
add_wave /tb_risc/r18_ok
add_wave /tb_risc/jal_link_seen

add_wave /tb_risc/skip_error_seen
add_wave /tb_risc/pc_escape_error
add_wave /tb_risc/zero_instr_error
add_wave /tb_risc/all_store_checks_ok
add_wave /tb_risc/all_register_checks_ok
add_wave /tb_risc/final_result_ok

run 5200ns

puts "================================================"
puts "RV32I Pipeline + Cache + AXI4 Simulation Complete"
puts "Console shows exact PASS/FAIL reason for each test item."
puts "Waveform proof:"
puts "1. clk/reset show simulation control"
puts "2. PCF/InstrF show instruction fetch"
puts "3. ResultW/rdW/RegWriteW and wd3/A3/we show writeback"
puts "4. Stall/Flush/Forward show pipeline hazard handling"
puts "5. I-cache and D-cache show memory requests"
puts "6. AXI4 AR/R and AW/W/B channels show memory transfers"
puts "7. WSTRB proves SW, SB, and SH store operations"
puts "8. Scoreboard flags show which instruction/result passed or failed"
puts "================================================"