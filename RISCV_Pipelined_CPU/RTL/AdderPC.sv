module AdderPC#(
    parameter ADDR_WIDTH = 32
) (
    input [ADDR_WIDTH - 1 : 0] PC_o,
    output [ADDR_WIDTH - 1 : 0] adder_o
);

assign adder_o = PC_o + 4;

endmodule

