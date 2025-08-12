module Control_Unit#(

) (
    input  [6:0] instruction,
    output       Branch,
    output       MemRead,
    output       MemtoReg,
    output [1:0] ALUOp,
    output       MemWrite,
    output       ALUSrc,
    output       RegWrite
);

logic        Branch_reg;
logic        MemRead_reg;
logic        MemtoReg_reg;
logic [1:0]  ALUOp_reg;
logic        MemWrite_reg;
logic        ALUSrc_reg;
logic        RegWrite_reg;

always_comb begin
    case (instruction)
        // R-type
        7'b0110011: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0]} = 8'b00100010;
        end
        // I-type
        7'b0010011: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0]} = 8'b10100000;
        end
        // Load-type
        7'b0000011: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0]} = 8'b11110000;
        end
        // Store-type
        7'b0100011: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0]} = 8'b10001000;
        end
        // Branch-type
        7'b1100011: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0]} = 8'b00000101;
        end
        default: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0]} = 8'b0;
        end
    endcase
end

assign Branch   = Branch_reg;
assign MemRead  = MemRead_reg;
assign MemtoReg = MemtoReg_reg;
assign ALUOp    = ALUOp_reg;
assign MemWrite = MemWrite_reg;
assign ALUSrc   = ALUSrc_reg;
assign RegWrite = RegWrite_reg;

endmodule