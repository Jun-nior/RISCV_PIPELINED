module Data_Memory #(
    parameter ADDR_WIDTH = 32,
    parameter DAT_WIDTH = 32
) (
    input                           clk,
    input                           rst_n,
    input   [ADDR_WIDTH - 1 : 0]    addr,
    input   [DAT_WIDTH - 1 : 0]     wdata,
    input                           MemWrite,
    input                           MemRead,
    output  [DAT_WIDTH - 1 : 0]     rdata
);

reg [DAT_WIDTH - 1 : 0] cpu_mem [0 : 63];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 64; i++) begin
            cpu_mem[i] <= i%64;
        end
    end else if (MemWrite) begin
        cpu_mem[addr%64] <= wdata;
    end
end

assign rdata = (MemRead) ? cpu_mem[addr%64] : 0;

endmodule