module Fetch_Stage #(
    parameter ADDR_WIDTH = 32
) (
    input                           clk,
    input                           rst_n,
    input                           PCSrc_E,
    input                           PC_Write,
    input                           IF_ID_Write,
    input   [ADDR_WIDTH - 1 : 0]    PCTarget_E,
    output  [ADDR_WIDTH - 1 : 0]    Ins_D,
    output  [ADDR_WIDTH - 1 : 0]    PC_4D,
    output  [ADDR_WIDTH - 1 : 0]    PC_D,

    // test_only
    input   [ADDR_WIDTH - 1 : 0]    tb_wdata_i
);

logic [ADDR_WIDTH - 1 : 0]      PC_F;
logic [ADDR_WIDTH - 1 : 0]      PCF;
logic [ADDR_WIDTH - 1 : 0]      PC_4F;
logic [ADDR_WIDTH - 1 : 0]      InsF;

logic [ADDR_WIDTH - 1 : 0]      InsF_r;
logic [ADDR_WIDTH - 1 : 0]      PCF_r;
logic [ADDR_WIDTH - 1 : 0]      PC_4F_r;

Mux PC_mux (
    .sel(PCSrc_E),
    .a(PC_4F),
    .b(PCTarget_E),
    .mux_o(PC_F)
);

Program_Counter Program_Counter(
    .clk(clk),
    .rst_n(rst_n),
    .PC_i(PC_F),
    .PC_Write(PC_Write),
    .PC_o(PCF)
);

// Instruction_Memory Instruction_Memory (
//     .clk(clk),
//     .rst_n(rst_n),
//     .raddr(PCF),
//     .im_o(InsF)
// );


assign InsF = tb_wdata_i;

AdderPC Adder_PC(
    .PC_o(PCF),
    .adder_o(PC_4F)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        InsF_r <= 'h0;
        PCF_r <= 'h0;
        PC_4F_r <= 'h0;
    end else if (PCSrc_E) begin // flush
        InsF_r <= 32'h00000013; // NOP: addi x0, x0, 0
        PCF_r <= 0;
        PC_4F_r <= 0;
    end else if (IF_ID_Write) begin // not stall by lw -> R
        InsF_r <= InsF;
        PCF_r <= PCF;
        PC_4F_r <= PC_4F;
    end else begin
        InsF_r <= InsF_r;
        PCF_r <= PCF_r;
        PC_4F_r <= PC_4F_r;
    end
end

assign Ins_D = InsF_r; 
assign PC_D  = PCF_r; 
assign PC_4D = PC_4F_r; 

endmodule