module CPU_Top #(
    parameter ADDR_WIDTH = 32,
    parameter DAT_WIDTH = 32
) (
    input   clk,
    input   rst_n,

    // Test-purpose outputs
    input   [ADDR_WIDTH - 1 : 0]    wdata_i,

    output  [ADDR_WIDTH - 1 : 0]    PC_o,
    output  [4:0]                   rd,
    output                          RegWrite,
    output                          RegWrite_M_o,
    output  [DAT_WIDTH - 1 : 0]     result_W_o,
    output  [4:0]                   rs1,
    output  [4:0]                   rs2,
    output  [ADDR_WIDTH - 1 : 0]    PC_F,
    output                          Branch_E_o,
    output                          PCSrc_E_o
);

logic                           PCSrc_E;
logic                           ALUSrc_E;
logic                           RegWrite_W;
logic                           RegWrite_E;
logic                           RegWrite_M;
logic                           MemWrite_E;
logic                           MemWrite_M;
logic                           MemRead_E;
logic                           MemRead_M;
logic                           MemtoReg_E;
logic                           MemtoReg_M;
logic                           MemtoReg_W;
logic                           Branch_E;
logic   [3:0]                   control_o;                   
logic   [4:0]                   rd_W;
logic   [4:0]                   rd_E;
logic   [4:0]                   rd_M;
logic   [4:0]                   rs1_E;
logic   [4:0]                   rs2_E;
logic   [ADDR_WIDTH - 1 : 0]    PCTarget_E;
logic   [ADDR_WIDTH - 1 : 0]    Ins_D;
logic   [ADDR_WIDTH - 1 : 0]    PC_D;
logic   [ADDR_WIDTH - 1 : 0]    PC_E;
logic   [ADDR_WIDTH - 1 : 0]    PC_4D;
logic   [ADDR_WIDTH - 1 : 0]    PC_4E;
logic   [ADDR_WIDTH - 1 : 0]    PC_4M;
logic   [ADDR_WIDTH - 1 : 0]    PC_4W;
logic   [DAT_WIDTH - 1 : 0]     Result_W;
logic   [DAT_WIDTH - 1 : 0]     rdata1_E;
logic   [DAT_WIDTH - 1 : 0]     rdata2_E;
logic   [DAT_WIDTH - 1 : 0]     ImmExt_E;
logic   [DAT_WIDTH - 1 : 0]     wdata_M;
logic   [DAT_WIDTH - 1 : 0]     ALU_result_M;
logic   [DAT_WIDTH - 1 : 0]     ALU_result_W;
logic   [DAT_WIDTH - 1 : 0]     rdata_W;
logic   [1:0]                   ForwardA_E;
logic   [1:0]                   ForwardB_E;

logic                           PC_Write;
logic                           IF_ID_Write;

Fetch_Stage Fetch (
    .clk(clk),
    .rst_n(rst_n),
    .PC_Write(PC_Write),
    .IF_ID_Write(IF_ID_Write),
    .PCTarget_E(PCTarget_E),
    .PCSrc_E(PCSrc_E),
    .tb_wdata_i(wdata_i),

    .Ins_D(Ins_D),
    .PC_D(PC_D),
    .PC_4D(PC_4D)
);

Decode_stage Decode (
    .clk(clk),
    .rst_n(rst_n),
    .RegWrite_W(RegWrite_W),
    .PCSrc_E(PCSrc_E),
    .rd_W(rd_W),
    .Ins_D(Ins_D),
    .PC_D(PC_D),
    .PC_4D(PC_4D),
    .Result_W(Result_W),

    .RegWrite_E(RegWrite_E),
    .ALUSrc_E(ALUSrc_E),
    .MemWrite_E(MemWrite_E),
    .MemRead_E(MemRead_E),
    .Branch_E(Branch_E),
    .MemtoReg_E(MemtoReg_E),
    .control_o_E(control_o),
    .ImmExt_E(ImmExt_E),
    .rdata1_E(rdata1_E),
    .rdata2_E(rdata2_E),
    .rs1_E(rs1_E),
    .rs2_E(rs2_E),
    .rd_E(rd_E),
    .PC_E(PC_E),
    .PC_4E(PC_4E),
    .PC_Write(PC_Write),
    .IF_ID_Write(IF_ID_Write)
);

Execute_Stage Execute (
    .clk(clk),
    .rst_n(rst_n),
    .RegWrite_E(RegWrite_E),
    .ALUSrc_E(ALUSrc_E),
    .MemWrite_E(MemWrite_E),
    .MemRead_E(MemRead_E),
    .Branch_E(Branch_E),
    .MemtoReg_E(MemtoReg_E),
    .wdata_W(Result_W),
    .control_o_i(control_o),
    .rdata1_E(rdata1_E),
    .rdata2_E(rdata2_E),
    .ImmExt_E(ImmExt_E),
    .rd_E(rd_E),
    .PC_E(PC_E),
    .PC_4E(PC_4E),
    .ForwardA_E(ForwardA_E),
    .ForwardB_E(ForwardB_E),

    .PCTarget_E(PCTarget_E),
    .PCSrc_E(PCSrc_E),
    .RegWrite_M(RegWrite_M),
    .MemWrite_M(MemWrite_M),
    .MemRead_M(MemRead_M),
    .MemtoReg_M(MemtoReg_M),
    .rd_M(rd_M),
    .PC_4M(PC_4M),
    .wdata_M(wdata_M),
    .ALU_result_M(ALU_result_M)
);

Memory_stage Memory (
    .clk(clk),
    .rst_n(rst_n),
    .RegWrite_M(RegWrite_M),
    .MemWrite_M(MemWrite_M),
    .MemRead_M(MemRead_M),
    .MemtoReg_M(MemtoReg_M),
    .rd_M(rd_M),
    .PC_4M(PC_4M),
    .wdata_M(wdata_M),
    .ALU_result_M(ALU_result_M),

    .RegWrite_W(RegWrite_W),
    .MemtoReg_W(MemtoReg_W),
    .rd_W(rd_W),
    .PC_4W(PC_4W),
    .ALU_result_W(ALU_result_W),
    .rdata_W(rdata_W)
);

Writeback_stage Writeback (
    .clk(clk),
    .rst_n(rst_n),
    .MemtoReg_W(MemtoReg_W),
    .PC_4W(PC_4W),
    .ALU_result_W(ALU_result_W),
    .rdata_W(rdata_W),

    .Result_W(Result_W)
);

F_Hazard F_Hazard (
    .rst_n(rst_n),
    .RegWrite_M(RegWrite_M),
    .RegWrite_W(RegWrite_W),
    .rd_M(rd_M),
    .rd_W(rd_W),
    .rs1_E(rs1_E),
    .rs2_E(rs2_E),

    .ForwardA_E(ForwardA_E),
    .ForwardB_E(ForwardB_E)
);
// Fetch
assign PC_o = Fetch.PCF;

// Decode
assign rs1 = Decode.Register_File.rs1;
assign rs2 = Decode.Register_File.rs2;

// WB
assign rd = rd_W;
assign RegWrite = RegWrite_W;
assign RegWrite_M_o = RegWrite_M;
assign result_W_o = Result_W;
assign PC_F = Fetch.PC_F;
assign Branch_E_o = Branch_E;
assign PCSrc_E_o = PCSrc_E;

endmodule