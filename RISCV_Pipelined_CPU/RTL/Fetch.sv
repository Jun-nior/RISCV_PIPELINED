module Fetch_Stage #(
    parameter ADDR_WIDTH = 32
)
(
    input                           clk;
    input                           rst_n;
    input   [ADDR_WIDTH - 1 : 0]    PCTargetE;
    input   [ADDR_WIDTH - 1 : 0]    PCSrcE;
    output  [ADDR_WIDTH - 1 : 0]    InsD;
    output  [ADDR_WIDTH - 1 : 0]    PC_4D;
    output  [ADDR_WIDTH - 1 : 0]    PC_D;
);

logic [ADDR_WIDTH - 1 : 0]      PC_F;
logic [ADDR_WIDTH - 1 : 0]      PCF;
logic [ADDR_WIDTH - 1 : 0]      PC_4F;
logic [ADDR_WIDTH - 1 : 0]      InsF;

logic [ADDR_WIDTH - 1 : 0]      InsF_r;
logic [ADDR_WIDTH - 1 : 0]      PCF_r;
logic [ADDR_WIDTH - 1 : 0]      PCF_4F_r;

Mux PC_mux (
    .sel(PCSrcE),
    .a(PC_4F),
    .b(PCTargetE),
    .c(PC_F)
);

PC Program_Counter(
    .clk(clk),
    .rst_n(rst_n),
    .PC_i(PC_F),
    .PC_o(PCF)
);

IM Instruction_Memory (
    .clk(clk),
    .rst_n(rst_n),
    .raddr(PCF),
    .im_o(InsF)
);

AdderPC Adder_PC(
    .PC_o(PCF),
    .adder_o(PC_4F)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        InsF_r <= 'h0;
        PCF_r <= 'h0;
        PC_4F_r <= 'h0;
    end else begin
        InsF_r <= InsF;
        PCF_r <= PCF;
        PC_4F_r <= PC_4F;
    end
end

assign InsD = (!rst)? 'h0 : InsF_r; 
assign PC_D = (!rst)? 'h0 : PCF_r; 
assign PC_4D = (!rst)? 'h0 : PC_4F_r; 

endmodule