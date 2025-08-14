module Decode_stage #(
    parameter ADDR_WIDTH = 32,
    parameter DAT_WIDTH = 32
) (
    input                           clk,
    input                           rst_n,
    input                           RegWrite_W,
    input   [4:0]                   rd_W,
    input   [ADDR_WIDTH - 1 : 0]    Ins_D,
    input   [ADDR_WIDTH - 1 : 0]    PC_D,
    input   [ADDR_WIDTH - 1 : 0]    PC_4D,
    input   [DAT_WIDTH - 1 : 0]     Result_W,

    output                          RegWrite_E,
    output                          ALUSrc_E,
    output                          MemWrite_E,
    output                          MemRead_E,
    output                          Branch_E,
    output                          MemtoReg_E, //ResultSrcE
    output                          [3:0] control_o_E,
    output  [DAT_WIDTH - 1 : 0]     ImmExt_E,
    output  [DAT_WIDTH - 1 : 0]     rdata1_E,
    output  [DAT_WIDTH - 1 : 0]     rdata2_E,
    output  [4:0]                   rs1_E,
    output  [4:0]                   rs2_E,
    output  [4:0]                   rd_E,
    output  [ADDR_WIDTH - 1 : 0]    PC_E,
    output  [ADDR_WIDTH - 1 : 0]    PC_4E
);

logic           RegWrite_D;
logic           Branch_D;
logic           MemRead_D;
logic           MemtoReg_D;
logic [1:0]     ALUOP_D;
logic           MemWrite_D;
logic           ALUSrc_D;
logic [3:0]     control_o_D;
logic [31:0]    ImmExt_D;
logic [31:0]    rdata1_D;
logic [31:0]    rdata2_D;
logic [31:0]    F_rdata1;
logic [31:0]    F_rdata2;
logic           ForwardID_A;
logic           ForwardID_B;

logic           RegWrite_r;
logic           ALUSrc_r;
logic           MemWrite_r;
logic           MemRead_r;
logic           Branch_r;
logic           MemtoReg_r;
logic [3:0]     control_o_r;  
logic [31:0]    ImmExt_r;
logic [31:0]    rdata1_r;
logic [31:0]    rdata2_r;
logic [4:0]     rs1_r; 
logic [4:0]     rs2_r; 
logic [4:0]     rd_r; 
logic [31:0]    PC_D_r; 
logic [31:0]    PC_4D_r; 

Control_Unit Control_Unit (
    .instruction(Ins_D[6:0]),
    .Branch(Branch_D),
    .MemRead(MemRead_D),
    .MemtoReg(MemtoReg_D),
    .ALUOp(ALUOP_D),
    .MemWrite(MemWrite_D),
    .ALUSrc(ALUSrc_D),
    .RegWrite(RegWrite_D)
);

ALU_Control ALU_Control (
    .ALUOp(ALUOP_D),
    .func7(Ins_D[30]),
    .func3(Ins_D[14:12]),
    .control_o(control_o_D)
);

Register_File Register_File (
    .clk(clk),
    .rst_n(rst_n),
    .rs1(Ins_D[19:15]),
    .rs2(Ins_D[24:20]),
    .rd(rd_W),
    .RegWrite(RegWrite_W),
    .wdata(Result_W),
    .rdata1(rdata1_D),
    .rdata2(rdata2_D)
);

Immediate_Generator Immediate_Generator (
    .instruction(Ins_D),
    .opcode(Ins_D[6:0]),
    .ImmExt(ImmExt_D)
);

ID_Hazard ID_Hazard (
    .rst_n(rst_n),
    .RegWrite_W(RegWrite_W),
    .rd_W(rd_W),
    .Ins_D(Ins_D),

    .ForwardID_A(ForwardID_A),
    .ForwardID_B(ForwardID_B)
);

Mux Forward_Mux_A (
    .sel(ForwardID_A),
    .a(rdata1_D),
    .b(Result_W),
    .mux_o(F_rdata1)
);

Mux Forward_Mux_B (
    .sel(ForwardID_B),
    .a(rdata2_D),
    .b(Result_W),
    .mux_o(F_rdata2)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        RegWrite_r <= 1'b0;
        ALUSrc_r   <= 1'b0;
        MemWrite_r <= 1'b0;
        MemRead_r  <= 1'b0;
        Branch_r   <= 1'b0;
        MemtoReg_r <= 1'b0;
        control_o_r <= 4'h0;
        ImmExt_r   <= 32'h0;
        rdata1_r   <= 32'h0;
        rdata2_r   <= 32'h0;
        rs1_r      <= 5'h0;
        rs2_r      <= 5'h0;
        rd_r      <= 5'h0;
        PC_D_r     <= 32'h0;
        PC_4D_r    <= 32'h0;
    end else begin
        RegWrite_r <= RegWrite_D;
        ALUSrc_r   <= ALUSrc_D;
        MemWrite_r <= MemWrite_D;
        MemRead_r  <= MemRead_D;
        Branch_r   <= Branch_D;
        MemtoReg_r <= MemtoReg_D;
        control_o_r <= control_o_D;
        ImmExt_r   <= ImmExt_D;
        rdata1_r   <= F_rdata1;
        rdata2_r   <= F_rdata2;
        rs1_r      <= Ins_D[19:15];
        rs2_r      <= Ins_D[24:20];
        rd_r       <= Ins_D[11:7];
        PC_D_r     <= PC_D;
        PC_4D_r    <= PC_4D;
    end
end

assign RegWrite_E   = RegWrite_r;
assign ALUSrc_E     = ALUSrc_r;
assign MemWrite_E   = MemWrite_r;
assign MemRead_E    = MemRead_r;
assign Branch_E     = Branch_r;
assign MemtoReg_E   = MemtoReg_r;
assign control_o_E = control_o_r;
assign ImmExt_E     = ImmExt_r;
assign rdata1_E       = rdata1_r;
assign rdata2_E       = rdata2_r;
assign rs1_E       = rs1_r;
assign rs2_E       = rs2_r;
assign rd_E       = rd_r;
assign PC_E        = PC_D_r;
assign PC_4E       = PC_4D_r;

endmodule