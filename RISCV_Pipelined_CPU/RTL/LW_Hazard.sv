module LW_Hazard (
    input           MemRead_E,
    input   [4:0]   rd_E,
    input   [4:0]   rs1_D,
    input   [4:0]   rs2_D,
    
    output          PC_Write,
    output          IF_ID_Write,
    output          Stall_E
);

logic   lw_hazard;
assign  lw_hazard = MemRead_E && (rd_E === rs1_D || rd_E === rs2_D);

assign  PC_Write = !lw_hazard; // freeze PC
assign  IF_ID_Write = !lw_hazard; // freeze IF/ID pipeline
assign  Stall_E = lw_hazard;

endmodule