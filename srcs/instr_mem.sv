`timescale 1ns / 1ps

module instr_mem(
    input  logic [31:0] A,   // Address input (byte address)
    output logic [31:0] RD   // Instruction output
);

    logic [31:0] mem [63:0];
    initial begin
        $readmemh("inst.mem", mem);
    end
    // Word-aligned read (divide address by 4)
    assign RD = mem[A[31:2]];

endmodule
