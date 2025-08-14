module F_Hazard (
    input           rst_n,
    input           RegWrite_M,
    input           RegWrite_W,
    input   [4:0]   rd_M,
    input   [4:0]   rd_W,
    input   [4:0]   rs1_E,
    input   [4:0]   rs2_E,
    output  [1:0]   ForwardA_E,
    output  [1:0]   ForwardB_E
);

assign ForwardA_E = (!rst_n) ? 0 : 
                    (RegWrite_M && rd_M != 0 && rd_M  == rs1_E) ? 2'b10 :
                    (RegWrite_W && rd_W != 0 && rd_W  == rs1_E) ? 2'b01 : 0;

assign ForwardB_E = (!rst_n) ? 0 : 
                    (RegWrite_M && rd_M != 0 && rd_M  == rs2_E) ? 2'b10 :
                    (RegWrite_W && rd_W != 0 && rd_W  == rs2_E) ? 2'b01 : 0;

endmodule