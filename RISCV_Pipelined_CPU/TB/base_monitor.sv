class base_monitor #(type T= uvm_sequence_item) extends uvm_monitor;
    `uvm_component_utils(base_monitor)
    uvm_analysis_port #(T) item_collected_port;

    function new (string name = "base_monitor", uvm_component parent);
        super.new(name,parent);
        item_collected_port = new("item_collected_port", this);
    endfunction
endclass

class fetch_monitor extends base_monitor #(fetch_item);
    `uvm_component_utils(fetch_monitor)

    virtual fetch_interface fetch_vif;
    virtual cpu_interface   cpu_vif;

    function new (string name = "fetch_monitor", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fetch_interface)::get(this,"","fetch_vif",fetch_vif)) begin
             `uvm_fatal("NOVIF", "Cannot get virtual interface handle for fetch_vif")
        end
        if (!uvm_config_db#(virtual cpu_interface)::get(this,"","cpu_vif",cpu_vif)) begin
             `uvm_fatal("NOVIF", "Cannot get virtual interface handle for cpu_vif")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        fetch_item item;
        @(posedge cpu_vif.rst_n);
        @(posedge fetch_vif.tb_cb);
        forever begin
            @(fetch_vif.tb_cb);
            // if (!$isunknown(fetch_vif.ins_i)) begin
                item = fetch_item::type_id::create("item");
                item.PC_o = fetch_vif.tb_cb.PC_o;
                item.instruction = fetch_vif.ins_i;
                `uvm_info(get_type_name(), $sformatf("Fetch Monitor get: \n%s", item.sprint()), UVM_HIGH)
                item_collected_port.write(item);
            // end
        end
    endtask
endclass

class writeback_monitor extends base_monitor #(wb_item);
    `uvm_component_utils(writeback_monitor)

    virtual writeback_interface wb_vif;

    function new (string name = "writeback_monitor", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual writeback_interface)::get(this,"","wb_vif",wb_vif)) begin
             `uvm_fatal("NOVIF", "Cannot get virtual interface handle for wb_vif")
        end
    endfunction

    virtual task run_phase (uvm_phase phase);
        wb_item item;
        forever begin
            @(posedge wb_vif.tb_cb);
            item = wb_item::type_id::create("item");
            if (wb_vif.tb_cb.RegWrite_W) begin
                item.rd = wb_vif.tb_cb.rd_W;
                item.result_W = wb_vif.tb_cb.result_W;
                `uvm_info(get_type_name(), $sformatf("WB Monitor get: \n%s", item.sprint()), UVM_HIGH)
                item_collected_port.write(item);
            end
        end
    endtask
endclass

class decode_monitor extends base_monitor #(decode_item);
    `uvm_component_utils(decode_monitor)

    virtual decode_interface dc_vif;
    virtual cpu_interface   cpu_vif;

    function new (string name = "decode_monitor", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual decode_interface)::get(this,"","dc_vif",dc_vif)) begin
             `uvm_fatal("NOVIF", "Cannot get virtual interface handle for dc_vif")
        end
        if (!uvm_config_db#(virtual cpu_interface)::get(this,"","cpu_vif",cpu_vif)) begin
             `uvm_fatal("NOVIF", "Cannot get virtual interface handle for cpu_vif")
        end
    endfunction

    virtual task run_phase (uvm_phase phase);
        decode_item item;
        logic       PCSrc_E_temp = 0;
        @(posedge cpu_vif.rst_n);
        repeat(2) begin
            @(posedge dc_vif.tb_cb);
        end
        forever begin
            @(posedge dc_vif.tb_cb);
            if (!PCSrc_E_temp) begin
                item = decode_item::type_id::create("item");
                item.rs1 = dc_vif.tb_cb.rs1;
                item.rs2 = dc_vif.tb_cb.rs2;
                `uvm_info(get_type_name(), $sformatf("DC Monitor get: \n%s", item.sprint()), UVM_HIGH)
                item_collected_port.write(item);
            end
            PCSrc_E_temp = dc_vif.tb_cb.PCSrc_E;
        end
    endtask
endclass

class exe_monitor extends base_monitor #(exe_item);
    `uvm_component_utils(exe_monitor)

    virtual exe_interface exe_vif;

    function new (string name = "exe_monitor", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual exe_interface)::get(this,"","exe_vif",exe_vif)) begin
             `uvm_fatal("NOVIF", "Cannot get virtual interface handle for exe_vif")
        end
    endfunction

    virtual task run_phase (uvm_phase phase);
        exe_item item;
        forever begin
            @(posedge exe_vif.tb_cb);
            if (exe_vif.tb_cb.Branch_E) begin
                item = exe_item::type_id::create("item");
                item.PC_F = exe_vif.tb_cb.PC_F;
                `uvm_info(get_type_name(), $sformatf("EXE Monitor get: \n%s", item.sprint()), UVM_HIGH)
                item_collected_port.write(item);
            end
        end
    endtask
endclass