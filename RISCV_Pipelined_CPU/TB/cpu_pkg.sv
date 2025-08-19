`ifndef CPU_PKG_SV
`define CPU_PKG_SV

package cpu_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    // `include "dut_if.sv"
    `include "base_item.sv"
    `include "base_sequence.sv"
    // `include "base_sequencer.sv"
    `include "base_driver.sv"
    `include "base_monitor.sv"
    `include "base_coverage.sv"
    `include "base_agent.sv"
    `include "base_scoreboard.sv"
    `include "base_env.sv"
    `include "base_test.sv"
endpackage

`endif