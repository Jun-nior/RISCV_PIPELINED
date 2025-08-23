`uvm_analysis_imp_decl(_fetch_cov) 
`uvm_analysis_imp_decl(_wb_cov)    
`uvm_analysis_imp_decl(_dc_cov)    
`uvm_analysis_imp_decl(_exe_cov)    
`uvm_analysis_imp_decl(_mem_cov)  

class base_coverage extends uvm_component;
    `uvm_component_utils(base_coverage)

    uvm_analysis_imp_fetch_cov #(fetch_item, base_coverage) fetch_imp;
    uvm_analysis_imp_wb_cov #(wb_item, base_coverage) wb_imp;
    uvm_analysis_imp_dc_cov #(decode_item, base_coverage) dc_imp;
    uvm_analysis_imp_exe_cov #(exe_item, base_coverage) exe_imp;
    uvm_analysis_imp_mem_cov #(mem_item, base_coverage) mem_imp;

    fetch_item  fetch_packet;
    wb_item     wb_packet;
    decode_item dc_packet;
    exe_item    exe_packet;
    mem_item    mem_packet;

    covergroup instr_mix_type;
        cp_inst_type: coverpoint fetch_packet.inst_type;
    endgroup

    covergroup rs_usage_cg;
        cp_rs1: coverpoint dc_packet.rs1;
        cp_rs2: coverpoint dc_packet.rs2;
        cross_reg: cross cp_rs1, cp_rs2;
    endgroup

    covergroup rd_usage_cg;
        cp_rd: coverpoint wb_packet.rd;
        cp_wdata: coverpoint wb_packet.result_W {
            option.auto_bin_max = 16;
        }
        cp_cross: cross cp_rd, cp_wdata;
    endgroup

    covergroup mem_stage;
        cp_addr: coverpoint mem_packet.addr {
            option.auto_bin_max = 16;
        }
        cp_wdata: coverpoint mem_packet.wdata {
            option.auto_bin_max = 16;
        }
        cp_cross: cross cp_addr, cp_wdata;
    endgroup

    function new(string name = "base_coverage", uvm_component parent = null);
        super.new(name, parent);

        fetch_imp = new("fetch_imp", this);
        wb_imp = new("wb_imp", this);
        dc_imp = new("dc_imp", this);
        exe_imp = new("exe_imp", this);
        mem_imp = new("mem_imp", this);

        instr_mix_type = new();
        rs_usage_cg = new();
        rd_usage_cg = new();
        mem_stage = new();
    endfunction

    function void write_fetch_cov(fetch_item t);
        this.fetch_packet = t;
        instr_mix_type.sample();
    endfunction

    function void write_wb_cov(wb_item t);
        this.wb_packet = t;
        rd_usage_cg.sample();
    endfunction

    function void write_dc_cov(decode_item t);
        this.dc_packet = t;
        rs_usage_cg.sample();
    endfunction

    function void write_exe_cov(exe_item t);
        this.exe_packet = t;
    endfunction

    function void write_mem_cov(mem_item t);
        this.mem_packet = t;
        mem_stage.sample();
    endfunction
endclass