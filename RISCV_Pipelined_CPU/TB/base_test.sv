class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    base_env env;
    base_sequence seq;
    im_add_sequence add_seq;
    reset_sequence reset_seq;

    function new (string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        env = base_env::type_id::create("env",this);
        // seq = base_sequence::type_id::create("seq");
        add_seq = im_add_sequence::type_id::create("add_seq");
        reset_seq = reset_sequence::type_id::create("reset_seq");
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        reset_seq.start(env.r_agt.sqr);
        add_seq.start(env.fetch_agt.sqr);
        #50;
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Finish starting add sequence", UVM_LOW)
    endtask

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "---UVM Testbench Topology---", UVM_LOW)
        uvm_root::get().print_topology();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("--COVERAGE--", "--- Functional Coverage Report ---", UVM_LOW)

        
        `uvm_info(  get_type_name(), 
                    $sformatf("Instruction Mix Coverage: %3.2f %%", env.cov.instr_mix_type.get_coverage()), 
                    UVM_LOW)
        `uvm_info(  get_type_name(), 
                    $sformatf("Rs used Coverage: %3.2f %%", env.cov.rs_usage_cg.get_coverage()), 
                    UVM_LOW)
        `uvm_info(  get_type_name(), 
                    $sformatf("Rd used Coverage: %3.2f %%", env.cov.rd_usage_cg.get_coverage()), 
                    UVM_LOW)
        `uvm_info(  get_type_name(), 
                    $sformatf("Memory Coverage: %3.2f %%", env.cov.mem_stage.get_coverage()), 
                    UVM_LOW)

        `uvm_info(get_type_name(), "----------------------------------", UVM_LOW)
    endfunction
endclass