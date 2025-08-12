module Adder #(
    parameter ADDR_WIDTH = 32
) (
    input   [ADDR_WIDTH - 1 : 0]    in1,
    input   [ADDR_WIDTH - 1 : 0]    in2,
    output  [ADDR_WIDTH - 1 : 0]    adder_o
);

assign adder_o = in1 + in2;

endmodule