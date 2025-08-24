module sva_checker #(
    parameter DAT_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)
(
    input                           clk,
    input                           rst_n,
    input                           PC_Write,

    input   [ADDR_WIDTH - 1 : 0]    PC,
    
    input                           RegWrite_W,
    input   [4:0]                   rd_W,
    input   [DAT_WIDTH - 1 : 0]     result_W,

    input   [4:0]                   rs1,
    input   [4:0]                   rs2,
    input                           PCSrc_E,
    input                           RegWrite_M,
    input                           Branch_E,

    input   [ADDR_WIDTH - 1 : 0]    addr,
    input   [DAT_WIDTH - 1 : 0]     wdata,
    input                           MemWrite
);

pc_on_reset: assert property(
    @(posedge clk)
    $fell(rst_n) |-> (PC == 32'b0)
) `uvm_info("ASSERT RESET", "PASS", UVM_LOW)
else `uvm_error("ASSERT RESET", "FAIL")

stall_by_PC_Write: assert property(
    @(posedge clk)
        disable iff (!rst_n)
            $fell(PC_Write) |-> ##1 $stable(PC)
) `uvm_info("ASSERT STALL", "PASS", UVM_LOW)
else `uvm_error("ASSERT STALL", "FAIL")

valid_wb: assert property(
    @(posedge clk)
        disable iff (!rst_n)
            (RegWrite_W) |-> !$isunknown(rd_W) && !$isunknown(result_W)
) `uvm_info("ASSERT WB", "PASS", UVM_LOW)
else `uvm_error("ASSERT WB", "FAIL")

valid_write_mem: assert property(
    @(posedge clk)
        disable iff (!rst_n)
            (MemWrite) |-> !$isunknown(addr) && !$isunknown(wdata) && !(RegWrite_M)
) `uvm_info("ASSERT WM", "PASS", UVM_LOW)
else `uvm_error("ASSERT WM", "FAIL")

branch_check: assert property(
    @(posedge clk)
        disable iff (!rst_n)
            (PCSrc_E) |-> Branch_E
) `uvm_info("ASSERT BRANCH", "PASS", UVM_LOW)
else `uvm_error("ASSERT BRANCH", "FAIL")

endmodule
