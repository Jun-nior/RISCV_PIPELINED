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

module Mux_3_1 #(
    parameter DAT_WIDTH = 32
) (
    input       [1:0]               sel,
    input       [DAT_WIDTH - 1 : 0] a,
    input       [DAT_WIDTH - 1 : 0] b,
    input       [DAT_WIDTH - 1 : 0] c,
    output      [DAT_WIDTH - 1 : 0] mux_o                         
);

assign mux_o = (sel == 2'b00) ? a : (sel == 2'b01) ? b : (sel == 2'b10) ? c : 0;

endmodule