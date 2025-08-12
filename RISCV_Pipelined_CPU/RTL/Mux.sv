module Mux #(
    parameter DAT_WIDTH = 32   
) (
    input                           sel,
    input       [DAT_WIDTH - 1 : 0] a,
    input       [DAT_WIDTH - 1 : 0] b,
    output      [DAT_WIDTH - 1 : 0] mux_o
);

assign mux_o = (!sel) ? a : b;

endmodule