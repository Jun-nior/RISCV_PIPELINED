class base_coverage extends uvm_subscriber #(fetch_item);
    `uvm_component_utils(base_coverage)

    fetch_item trans;

    covergroup instr_mix_type;
        cp_inst_type: coverpoint trans.inst_type;
    endgroup

    covergroup reg_usage_cg;
        cp_rs1: coverpoint trans.rs1;
        cp_rs2: coverpoint trans.rs2;
        cp_rd:  coverpoint trans.rd;
        cross_reg: cross cp_rs1, cp_rs2, cp_rd;
    endgroup

    covergroup immediate_cg;
        cp_i_im: coverpoint trans.imm {
            bins zero = {0};
            bins max_pos = {[2000:$]};
            bins max_neg = {[-2048:-2000]};
            bins others = default;
        }
        cp_im: coverpoint trans.imm {
            bins forward = {[0:$]};
            bins backward = {[$:-1]};
        }
        cp_j_im: coverpoint trans.j_imm {
            bins positive = {[1:$]};  
            bins negative = {[$:-1]}; 
            bins zero     = {0};
        }
        cp_b_im: coverpoint trans.b_imm {
            bins positive = {[1:$]};  
            bins negative = {[$:-1]}; 
            bins zero     = {0};
        }
    endgroup

    covergroup basic_inst_type_writes_to_rd;
        cp_inst: coverpoint trans.inst_type {
            bins user_test = {ADD, SUB, AND, OR, XOR};
        }
        cp_rd: coverpoint trans.rd;
        cross_inst_rd: cross cp_inst, cp_rd;
    endgroup

    covergroup i_type_immediate;
        cp_inst: coverpoint trans.inst_type {
            bins i_type = {ADDI, ORI, XORI, ANDI};
        }
        cp_imm: coverpoint trans.imm {
            option.auto_bin_max = 64;
        }
        cross_inst_imm: cross cp_inst, cp_imm;
    endgroup
    
    covergroup j_b_immediate;
        cp_j: coverpoint trans.inst_type {
            bins i_type = {JAL};
        }
        cp_b: coverpoint trans.inst_type {
            bins i_type = {BNE,BEQ};
        }
        cp_j_imm: coverpoint trans.j_imm {
            option.auto_bin_max = 64;
        }
        cp_b_imm: coverpoint trans.b_imm {
            option.auto_bin_max = 64;
        }
        cross_j_imm: cross cp_j, cp_j_imm;
        cross_b_imm: cross cp_b, cp_b_imm;
    endgroup

    function new(string name = "base_coverage", uvm_component parent = null);
        super.new(name, parent);
        instr_mix_type = new();
        reg_usage_cg = new();
        immediate_cg = new();
        basic_inst_type_writes_to_rd = new();
        i_type_immediate = new();
        j_b_immediate = new();
    endfunction

    function void write(fetch_item t);
        this.trans = t;
        instr_mix_type.sample();
        reg_usage_cg.sample();
        immediate_cg.sample();
        basic_inst_type_writes_to_rd.sample();
        i_type_immediate.sample();
        j_b_immediate.sample();
    endfunction
endclass