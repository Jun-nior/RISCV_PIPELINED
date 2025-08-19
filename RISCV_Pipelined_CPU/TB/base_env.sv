class base_env extends uvm_env;
    `uvm_component_utils(base_env)

    base_agent      agt;
    fetch_agent     fetch_agt;
    wb_agent        wb_agt;
    decode_agent    dc_agt;
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
        dc_agt = decode_agent::type_id::create("dc_agt",this);
        scb = im_scoreboard::type_id::create("scb", this);
        cov = base_coverage::type_id::create("cov",this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        fetch_agt.mon.item_collected_port.connect(this.scb.fetch_imp);
        wb_agt.mon.item_collected_port.connect(this.scb.wb_imp);
        dc_agt.mon.item_collected_port.connect(this.scb.dc_imp);
        // fetch_agt.drv.item_driven_port.connect(this.cov.analysis_export);
    endfunction
endclass