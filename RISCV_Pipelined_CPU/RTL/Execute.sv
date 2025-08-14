module Execute_Stage #(
    parameter ADDR_WIDTH = 32,
    parameter DAT_WIDTH  = 32
) (
    input                           clk,
    input                           rst_n,
    input                           RegWrite_E,
    input                           ALUSrc_E,
    input                           MemWrite_E,
    input                           MemRead_E,
    input                           Branch_E,
    input                           MemtoReg_E,
    input   [DAT_WIDTH - 1 : 0]     wdata_W,
    input   [3:0]                   control_o_i,
    input   [1:0]                   ForwardA_E,
    input   [1:0]                   ForwardB_E,
    input   [DAT_WIDTH - 1 : 0]     rdata1_E,
    input   [DAT_WIDTH - 1 : 0]     rdata2_E,
    input   [DAT_WIDTH - 1 : 0]     ImmExt_E,
    input   [4:0]                   rd_E,
    input   [ADDR_WIDTH - 1 : 0]    PC_E,
    input   [ADDR_WIDTH - 1 : 0]    PC_4E,

    output  [ADDR_WIDTH - 1 : 0]    PCTarget_E,
    output                          PCSrc_E,
    output                          RegWrite_M,
    output                          MemWrite_M,
    output                          MemRead_M,
    output                          MemtoReg_M,
    output  [4:0]                   rd_M,
    output  [ADDR_WIDTH - 1 : 0]    PC_4M,
    output  [DAT_WIDTH - 1 : 0]     wdata_M,
    output  [DAT_WIDTH - 1 : 0]     ALU_result_M
);

logic   [31:0]  SrcB_E;
logic   [31:0]  Result;
logic           zero_E;

logic           RegWrite_r;
logic           MemWrite_r;
logic           MemRead_r;
logic           MemtoReg_r;

logic   [4:0]                   rd_r;
logic   [31:0]                  ALU_Result_r;
logic   [ADDR_WIDTH - 1 : 0]    PC_4E_r;
logic   [DAT_WIDTH - 1 : 0]     rdata2_r;
logic   [DAT_WIDTH - 1 : 0]     SrcA_E;
logic   [DAT_WIDTH - 1 : 0]     SrcB_E2;

Mux ALU_Mux (
    .sel(ALUSrc_E),
    .a(SrcB_E2),
    .b(ImmExt_E),
    .mux_o(SrcB_E) 
);

ALU ALU (
    .in1(SrcA_E),
    .in2(SrcB_E),
    .control_i(control_o_i),
    .ALU_o(Result),
    .zero(zero_E),
    .overflow(),
    .carry(),
    .negative()
);

Adder AdderPC (
    .in1(PC_E),
    .in2(ImmExt_E),
    .adder_o(PCTarget_E)
);

AND AND (
    .branch(Branch_E),
    .zero(zero_E),
    .and_o(PCSrc_E)
);

Mux_3_1 SrcA (
    .sel(ForwardA_E),
    .a(rdata1_E),
    .b(wdata_W),
    .c(ALU_result_M),
    .mux_o(SrcA_E)
);

Mux_3_1 SrcB (
    .sel(ForwardB_E),
    .a(rdata2_E),
    .b(wdata_W),
    .c(ALU_result_M),
    .mux_o(SrcB_E2)
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        RegWrite_r <= 1'b0; 
        MemWrite_r <= 1'b0; 
        MemRead_r <= 1'b0; 
        MemtoReg_r <= 1'b0;
        rd_r <= 5'h00;
        PC_4E_r <= 32'h00000000; 
        rdata2_r <= 32'h00000000; 
        ALU_Result_r <= 32'h00000000;
    end
    else begin
        RegWrite_r <= RegWrite_E; 
        MemWrite_r <= MemWrite_E; 
        MemRead_r <= MemRead_E; 
        MemtoReg_r <= MemtoReg_E;
        rd_r <= rd_E;
        PC_4E_r <= PC_4E; 
        rdata2_r <= SrcB_E2; 
        ALU_Result_r <= Result;
    end
end

assign RegWrite_M = RegWrite_r;
assign MemWrite_M = MemWrite_r;
assign MemRead_M = MemRead_r;
assign MemtoReg_M = MemtoReg_r;
assign rd_M = rd_r;
assign PC_4M = PC_4E_r;
assign wdata_M = rdata2_r;
assign ALU_result_M = ALU_Result_r;

endmodule