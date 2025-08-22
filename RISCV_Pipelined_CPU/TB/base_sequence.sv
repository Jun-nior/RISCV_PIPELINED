class base_sequence #(type REQ = uvm_sequence_item, RSP = REQ) extends uvm_sequence#(REQ, RSP);
    `uvm_object_utils(base_sequence)

    function new (string name = "base_sequence");
        super.new(name);
    endfunction

endclass

class im_add_sequence extends base_sequence#(fetch_item);
    `uvm_object_utils(im_add_sequence)

    function new (string name = "im_add_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat(1000) begin
            // `uvm_do(req)
            `uvm_do_with(req, {inst_type inside {ADD, OR, AND, XOR, ADDI, ORI, ANDI , XORI, BEQ};})
            // `uvm_do_with(req, {inst_type == ADD; rs1 == 2; rs2 == 4; rd == 3;})
            // `uvm_do_with(req, {inst_type == BEQ; rs1 == 3; rs2 == 6; b_imm == 100;})    
            // `uvm_do_with(req, {inst_type inside {ADD,BEQ};})
            `uvm_info($sformatf("%s", req.inst_type), $sformatf("Sending instruction %h", req.instruction), UVM_LOW)
        end
        `uvm_do_with(req, {instruction == 'hx;})
        `uvm_info(get_type_name(), "Finish creating instruction", UVM_LOW)
    endtask
endclass

class reset_sequence extends base_sequence#(reset_item);
    `uvm_object_utils(reset_sequence)

    function new (string name = "reset_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do_with(req, {
            rst_n == 0;
        })
        `uvm_do_with(req, {
            rst_n == 1;
        })
        `uvm_info(get_type_name(), "Finish reset", UVM_LOW)
    endtask
endclass