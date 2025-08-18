module ALU_Control #(

) (
    input   [1:0]   ALUOp,
    input           func7,
    input   [2:0]   func3,
    output  [3:0]   control_o
);

logic [3:0] control_o_reg;

always_comb begin
    case (ALUOp)
        // ALUOp for I-type
        2'b00: begin
            case (func3)
                3'b000: control_o_reg = 4'b0010; // ADDI, LW, SW
                3'b110: control_o_reg = 4'b0001; // ORI 
                3'b100: control_o_reg = 4'b0100; // XORI 
                3'b111: control_o_reg = 4'b0000;
                default: control_o_reg = 4'bxxxx;
            endcase
        end

        // ALUOp for BEQ 
        2'b01: control_o_reg = 4'b0110; // SUB

        // ALUOp for R-type
        2'b10: begin
            case ({func7, func3})
                4'b0_000: control_o_reg = 4'b0010; // ADD
                4'b1_000: control_o_reg = 4'b0110; // SUB
                4'b0_111: control_o_reg = 4'b0000; // AND
                4'b0_110: control_o_reg = 4'b0001; // OR
                4'b0_100: control_o_reg = 4'b0100; // XOR
                default:  control_o_reg = 4'bxxxx;
            endcase
        end
        default: control_o_reg = 4'bxxxx;
    endcase
end

assign control_o = control_o_reg;

endmodule