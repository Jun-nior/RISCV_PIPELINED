module Memory_stage #(
    parameter ADDR_WIDTH = 32,
    parameter DAT_WIDTH = 32
) (
    input                           clk,
    input                           rst_n,
    input                           RegWrite_M,
    input                           MemWrite_M,
    input                           MemRead_M,
    input                           MemtoReg_M,
    input   [4:0]                   rd_M,
    input   [ADDR_WIDTH - 1 : 0]    PC_4M,
    input   [DAT_WIDTH - 1 : 0]     wdata_M,
    input   [DAT_WIDTH - 1 : 0]     ALU_result_M,

    output                          RegWrite_W,
    output                          MemtoReg_W,
    output  [4:0]                   rd_W,
    output  [ADDR_WIDTH - 1 : 0]    PC_4W,
    output  [DAT_WIDTH - 1 : 0]     ALU_result_W,
    output  [DAT_WIDTH - 1 : 0]     rdata_W
);

logic   [DAT_WIDTH - 1 : 0]     rdata_M;

logic                           RegWrite_r;
// logic                           MemRead_r;
logic                           MemtoReg_r;
logic   [4:0]                   rd_r;
logic   [ADDR_WIDTH - 1 : 0]    PC_4M_r;
logic   [DAT_WIDTH - 1 : 0]     ALU_Result_r;
logic   [DAT_WIDTH - 1 : 0]     rdata_r;

Data_Memory Data_Memory (
    .clk(clk),
    .rst_n(rst_n),
    .addr(ALU_result_M),
    .wdata(wdata_M),
    .MemWrite(MemWrite_M),
    .MemRead(MemRead_M),
    .rdata(rdata_M)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        RegWrite_r <= 'b0;
        // MemRead_r <= 'b0;
        MemtoReg_r <= 'b0;
        rd_r <= 'b0;
        PC_4M_r <= 'h0;
        ALU_Result_r <= 'h0;
        rdata_r <= 'h0;
    end else begin
        RegWrite_r <= RegWrite_M;
        // MemRead_r <= MemRead_M;
        MemtoReg_r <= MemtoReg_M;
        rd_r <= rd_M;
        PC_4M_r <= PC_4M;
        ALU_Result_r <= ALU_result_M;
        rdata_r <= rdata_M;
    end
end

assign RegWrite_W = RegWrite_r;
assign MemtoReg_W = MemtoReg_r;
assign rd_W = rd_r;
assign PC_4W = PC_4M_r;
assign ALU_result_W = ALU_Result_r;
assign rdata_W = rdata_r;

endmodule