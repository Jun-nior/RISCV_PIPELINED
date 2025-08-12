module Program_Counter#(
    parameter ADDR_WIDTH = 32  
) (
    input                           clk,
    input                           rst_n,
    input   [ADDR_WIDTH - 1 : 0]    PC_i,
    output  [ADDR_WIDTH - 1 : 0]    PC_o
);

logic   [ADDR_WIDTH - 1 : 0]    PC_o_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        PC_o_reg <= -4;
    end else begin
        PC_o_reg <= PC_i;
    end
end 

assign PC_o = PC_o_reg;

endmodule