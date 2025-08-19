class base_sequencer extends uvm_sequencer#(base_item);
    `uvm_component_utils(base_sequencer)

    function new (string name = "base_sequencer", uvm_component parent);
        super.new(name,parent);
    endfunction
endclass