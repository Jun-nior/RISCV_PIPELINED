module Writeback_stage #(
    parameter ADDR_WIDTH = 32,
    parameter DAT_WIDTH = 32
) (
    input                           clk,
    input                           rst_n,
    input                           MemtoReg_W,
    input   [ADDR_WIDTH - 1 : 0]    PC_4W,
    input   [DAT_WIDTH - 1 : 0]     ALU_result_W,
    input   [DAT_WIDTH - 1 : 0]     rdata_W,

    output  [DAT_WIDTH - 1 : 0]     Result_W
);

Mux WB_Mux (
    .sel(MemtoReg_W),
    .a(ALU_result_W),
    .b(rdata_W),
    .mux_o(Result_W)
);

endmodule