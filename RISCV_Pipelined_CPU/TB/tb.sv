`include "uvm_macros.svh"
import uvm_pkg::*;
import cpu_pkg::*;
`include "dut_if.sv"
`include "sva_checker.sv"

module CPU_Top_tb_top;

    logic clk;

    cpu_interface cpu_if (
        .clk(clk)
    );

    fetch_interface fetch_if (
        .clk(clk)
    );

    writeback_interface wb_if (
        .clk(clk)
    );

    decode_interface dc_if (
        .clk(clk)
    );

    exe_interface exe_if (
        .clk(clk)
    );

    mem_interface mem_if (
        .clk(clk)
    );

    CPU_Top dut (
        .clk(clk),
        .rst_n(cpu_if.rst_n),
        .wdata_i(fetch_if.ins_i),
        .PC_o(fetch_if.PC_o),
        .rd(wb_if.rd_W),
        .RegWrite(wb_if.RegWrite_W),
        .RegWrite_M_o(dc_if.RegWrite_M),
        .result_W_o(wb_if.result_W),
        .rs1(dc_if.rs1),
        .rs2(dc_if.rs2),
        .PC_F(exe_if.PC_F),
        .Branch_E_o(exe_if.Branch_E),
        .PCSrc_E_o(dc_if.PCSrc_E),
        .MemWrite_o(mem_if.MemWrite),
        .wdata(mem_if.wdata),
        .addr(mem_if.addr),
        .PC_Write_o(cpu_if.PC_Write)
    );

    bind CPU_Top sva_checker assertion_inst (
        .clk(clk),
        .rst_n(rst_n),
        .PC_Write(PC_Write_o),
        .PC(PC_o),
        .RegWrite_W(RegWrite),
        .rd_W(rd),
        .result_W(result_W_o),
        .rs1(rs1),
        .rs2(rs2),
        .PCSrc_E(PCSrc_E_o),
        .RegWrite_M(RegWrite_M_o),
        .Branch_E(Branch_E_o),
        .addr(addr),
        .wdata(wdata),
        .MemWrite(MemWrite_o)
    );

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        uvm_config_db#(virtual fetch_interface)::set(null,"*","fetch_vif",fetch_if);
        uvm_config_db#(virtual cpu_interface)::set(null,"*","cpu_vif",cpu_if);
        uvm_config_db#(virtual writeback_interface)::set(null,"*","wb_vif",wb_if);
        uvm_config_db#(virtual decode_interface)::set(null,"*","dc_vif",dc_if);
        uvm_config_db#(virtual exe_interface)::set(null,"*","exe_vif",exe_if);
        uvm_config_db#(virtual mem_interface)::set(null,"*","mem_vif",mem_if);
        run_test("base_test");
    end

endmodule