module sva_checker #(
    parameter DAT_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)
(
    input clk,
    input rst_n,
    input MemRead,
    input MemWrite,
    input RegWrite,
    input Branch,
    input [ADDR_WIDTH - 1 : 0] PC
);

pc_on_reset: assert property(
    @(posedge clk)
    $fell(rst_n) |-> (PC == 32'b0)
) `uvm_info("ASSERT", "PASS", UVM_HIGH)
else `uvm_error("ASSERT", "FAIL")

a_mem_read_write_exclusive: assert property (
    @(posedge clk) 
        disable iff (!rst_n)
        !(MemRead && MemWrite)
) `uvm_info("ASSERT", "PASS", UVM_HIGH)
else `uvm_error("ASSERT", "FAIL")

a_store_no_reg_write: assert property (
    @(posedge clk) 
        disable iff (!rst_n)
        MemWrite |-> !RegWrite
) `uvm_info("ASSERT", "PASS", UVM_HIGH)
else `uvm_error("ASSERT", "FAIL")


a_branch_no_reg_write: assert property (
    @(posedge clk) 
        disable iff (!rst_n)
        Branch |-> !RegWrite
) `uvm_info("ASSERT", "PASS", UVM_HIGH)
else `uvm_error("ASSERT", "FAIL")

endmodule
