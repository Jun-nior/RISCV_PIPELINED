module Immediate_Generator#(
    parameter ADDR_WIDTH = 32
) (
    input   [ADDR_WIDTH - 1 : 0]    instruction,
    input   [6:0]                   opcode,
    output  [31:0]                  ImmExt
);

logic   [31:0]  ImmExt_reg;

always @(*) begin
    case (opcode)
        // I-type
        7'b0010011: begin
            ImmExt_reg = {{20{instruction[31]}}, instruction[31:20]};
        end 
        // Load-type
        7'b0000011: begin
            ImmExt_reg = {{20{instruction[31]}}, instruction[31:20]};                     
        end
        // Store-type
        7'b0100011: begin
            ImmExt_reg = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};  
        end
        // Branch-type
        7'b1100011: begin
            ImmExt_reg = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // shift left 1 here (adding 0 at the end)
        end
        default: begin
            ImmExt_reg = 32'b0;
        end
    endcase
end

assign ImmExt = ImmExt_reg;

endmodule