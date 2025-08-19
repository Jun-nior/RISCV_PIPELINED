interface cpu_interface(input logic clk);
    logic rst_n;

    clocking tb_cb @(posedge clk);
        output rst_n;
    endclocking
endinterface

interface fetch_interface (input logic clk);
    logic [31:0] PC_o;
    logic [31:0] ins_i;

    clocking tb_cb @(posedge clk);
        input  PC_o;
        output ins_i;
    endclocking

    modport DUT (
        output PC_o,
        input  ins_i
    );
endinterface

interface writeback_interface (input logic clk);

    logic        RegWrite_W; 
    logic [4:0]  rd_W;       
    logic [31:0] result_W;   

    clocking tb_cb @(posedge clk);
        input RegWrite_W, rd_W, result_W;
    endclocking

    modport DUT (
        output RegWrite_W, rd_W, result_W
    );

endinterface

interface decode_interface (input logic clk);

    logic [4:0]  rs1;       
    logic [4:0]  rs2;       

    clocking tb_cb @(posedge clk);
        input rs1, rs2;
    endclocking

    modport DUT (
        output rs1, rs2
    );

endinterface