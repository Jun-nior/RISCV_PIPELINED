module Instruction_Memory#(
    parameter ADDR_WIDTH = 32,
    parameter MEM_SIZE = 64
) (
    input                           clk,
    input                           rst_n,
    input   [ADDR_WIDTH - 1 : 0]    raddr,
    output  [ADDR_WIDTH - 1 : 0]    im_o
);
logic [ADDR_WIDTH - 1 : 0] i_mem [0 : MEM_SIZE - 1];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < MEM_SIZE; i++) begin
            i_mem[i] <= 'b0;
        end
    end else begin
        i_mem[0] = 32'b0;
        i_mem[4] = 32'b000000_11001_10000_000_01101_0110011;
        i_mem[8] = 32'b000000_00011_00010_111_00001_0110011;
        i_mem[12] = 32'b000000000011_10101_000_10110_0010011;
        i_mem[16] = 32'b0100000_00100_01000_000_00111_0110011;
        i_mem[20] = 32'b000000001111_00101_010_01000_0000011;
        i_mem[24] = 32'b0000000_01110_00110_010_01010_0100011;
        i_mem[28] = 32'h00948663;
    end
end

assign im_o = i_mem[raddr];

endmodule