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
        $readmemh("./RTL/memfile.hex", i_mem);
    end
end

assign im_o = i_mem[raddr[ADDR_WIDTH - 1 : 2]];

endmodule