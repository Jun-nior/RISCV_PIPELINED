class base_env extends uvm_env;
    `uvm_component_utils(base_env)

    base_agent      agt;
    fetch_agent     fetch_agt;
    wb_agent        wb_agt;
    decode_agent    dc_agt;
    exe_agent       exe_agt;
    mem_agent       mem_agt;
    reset_agent     r_agt;

    im_scoreboard   scb;
    base_coverage   cov;

    function new (string name = "base_env", uvm_component parent);
        super.new(name,parent);
    endfunction    

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        // agt = base_agent::type_id::create("agt",this);
        r_agt = reset_agent::type_id::create("r_agt",this);
        fetch_agt = fetch_agent::type_id::create("fetch_agt",this);
        wb_agt = wb_agent::type_id::create("wb_agt",this);
        mem_agt = mem_agent::type_id::create("mem_agt",this);
        dc_agt = decode_agent::type_id::create("dc_agt",this);
        exe_agt = exe_agent::type_id::create("exe_agt",this);
        scb = im_scoreboard::type_id::create("scb", this);
        cov = base_coverage::type_id::create("cov",this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        fetch_agt.mon.item_collected_port.connect(this.scb.fetch_imp);
        fetch_agt.drv.item_driven_port.connect(this.cov.fetch_imp);
        wb_agt.mon.item_collected_port.connect(this.scb.wb_imp);
        wb_agt.mon.item_driven_port.connect(this.cov.wb_imp);
        dc_agt.mon.item_collected_port.connect(this.scb.dc_imp);
        dc_agt.mon.item_driven_port.connect(this.cov.dc_imp);
        exe_agt.mon.item_collected_port.connect(this.scb.exe_imp);
        exe_agt.mon.item_driven_port.connect(this.cov.exe_imp);
        mem_agt.mon.item_collected_port.connect(this.scb.mem_imp);
        mem_agt.mon.item_driven_port.connect(this.cov.mem_imp);
    endfunction
endclass