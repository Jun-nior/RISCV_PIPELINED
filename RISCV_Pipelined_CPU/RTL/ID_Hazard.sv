module ID_Hazard (
    input           rst_n,
    input           RegWrite_W,
    input           rd_W,
    input   [31:0]  Ins_D,

    output          ForwardID_A,
    output          ForwardID_B
);

assign ForwardID_A =    (!rst_n) ? 0 : 
                        (RegWrite_W && rd_W != 0 && rd_W == Ins_D[19:15]);

assign ForwardID_B =    (!rst_n) ? 0 : 
                        (RegWrite_W && rd_W != 0 && rd_W == Ins_D[24:20]);

endmodule