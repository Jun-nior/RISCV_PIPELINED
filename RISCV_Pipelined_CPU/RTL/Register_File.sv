module Register_File #(
    parameter ADDR_WIDTH = 32,
    parameter DAT_WIDTH = 32
) (
    input                       clk,
    input                       rst_n,
    input   [4:0]               rs1,
    input   [4:0]               rs2,
    input   [4:0]               rd,
    input                       RegWrite,
    input   [DAT_WIDTH - 1 : 0] wdata,
    output  [DAT_WIDTH - 1 : 0] rdata1, 
    output  [DAT_WIDTH - 1 : 0] rdata2 
);

logic [DAT_WIDTH - 1 : 0] reg_mem [0:31];

initial begin
    reg_mem[0]  = 0;
    reg_mem[1]  = 1;
    reg_mem[2]  = 2;
    reg_mem[3]  = 3;
    reg_mem[4]  = 4;
    reg_mem[5]  = 5;
    reg_mem[6]  = 6;
    reg_mem[7]  = 7;
    reg_mem[8]  = 8;
    reg_mem[9]  = 9;
    reg_mem[10] = 10;
    reg_mem[11] = 11;
    reg_mem[12] = 12;
    reg_mem[13] = 13;
    reg_mem[14] = 14;
    reg_mem[15] = 15;
    reg_mem[16] = 16;
    reg_mem[17] = 17;
    reg_mem[18] = 18;
    reg_mem[19] = 19;
    reg_mem[20] = 20;
    reg_mem[21] = 21;
    reg_mem[22] = 22;
    reg_mem[23] = 23;
    reg_mem[24] = 24;
    reg_mem[25] = 25;
    reg_mem[26] = 26;
    reg_mem[27] = 27;
    reg_mem[28] = 28;
    reg_mem[29] = 29;
    reg_mem[30] = 30;
    reg_mem[31] = 31;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 32; i++) begin
            reg_mem[i] <= i;
        end
    end else if (RegWrite) begin
        reg_mem[rd] <= wdata;
    end
end

assign rdata1 = reg_mem[rs1];
assign rdata2 = reg_mem[rs2];

endmodule