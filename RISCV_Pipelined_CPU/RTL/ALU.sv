module ALU #(
    
) (
    input   [31:0]  in1,
    input   [31:0]  in2,
    input   [3:0]   control_i,
    output signed [31:0]  ALU_o,
    output          zero,
    output          overflow,
    output          carry,
    output          negative 
);

logic   [31:0]  ALU_o_reg;
logic           zero_reg;
logic           overflow_reg;
logic           carry_reg; 
logic           negative_reg;
logic [32:0] temp_result;

always @(control_i or in1 or in2) begin
zero_reg = 1'b0;
overflow_reg = 1'b0;
carry_reg = 1'b0;


    case (control_i)
        4'b0000: begin // AND
            ALU_o_reg = in1 & in2;
        end
        4'b0001: begin // OR
            ALU_o_reg = in1 | in2;
        end
        4'b0010: begin // ADD
            temp_result = {1'b0, in1} + {1'b0, in2};
            ALU_o_reg = temp_result[31:0];
            carry_reg = temp_result[32]; 
            if (in1[31] == in2[31] && ALU_o_reg[31] != in1[31]) begin
                overflow_reg = 1'b1;
            end
        end
        4'b0110: begin // SUB
            temp_result = {1'b0, in1} - {1'b0, in2};
            ALU_o_reg = temp_result[31:0];
            carry_reg = ~temp_result[32]; 
            if (in1[31] != in2[31] && ALU_o_reg[31] != in1[31]) begin
                overflow_reg = 1'b1;
            end
        end
        default: begin
            ALU_o_reg = 32'h0;
        end
    endcase

    if (ALU_o_reg == 32'h0) begin
        zero_reg = 1'b1;
    end
    negative_reg = ALU_o_reg[31];
end

assign ALU_o = ALU_o_reg;
assign zero = zero_reg;
assign overflow = overflow_reg;
assign carry = carry_reg;
assign negative = negative_reg;

endmodule