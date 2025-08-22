`define UVM_COLOR_PASS "\033[0;32m" // Green
`define UVM_COLOR_FAIL "\033[0;31m" // Red
`define UVM_COLOR_RESET "\033[0m"   // Reset to default color

`uvm_analysis_imp_decl(_fetch) 
`uvm_analysis_imp_decl(_wb)    
`uvm_analysis_imp_decl(_dc)    
`uvm_analysis_imp_decl(_exe)    

class base_scoreboard #(type T = uvm_sequence_item) extends uvm_scoreboard;
    `uvm_component_utils(base_scoreboard)

    uvm_analysis_imp_fetch #(fetch_item, base_scoreboard) fetch_imp;
    uvm_analysis_imp_wb #(wb_item, base_scoreboard) wb_imp;
    uvm_analysis_imp_dc #(decode_item, base_scoreboard) dc_imp;
    uvm_analysis_imp_exe #(exe_item, base_scoreboard) exe_imp;

    fetch_item fetch_arr[$];
    wb_item wb_arr[$];
    decode_item dc_arr[$];
    exe_item exe_arr[$];

    fetch_item fetch_packet;
    fetch_item fetch_packet_tmp;

    wb_item wb_packet;
    decode_item dc_packet;

    decode_item dc_packet_tmp;
    exe_item    exe_packet;

    int         stage = 0;
    logic [31:0]    expected_result_hz;
    logic [4:0]     e_rd_hz;

    function new (string name = "base_scoreboard", uvm_component parent);
        super.new(name,parent);
        fetch_imp = new("fetch_imp", this);
        wb_imp = new("wb_imp", this);
        dc_imp = new("dc_imp", this);
        exe_imp = new("exe_imp", this);
    endfunction
    
    function void write_fetch(fetch_item item);
        fetch_arr.push_back(item);
        `uvm_info(get_type_name(), "Push item to fetch arr", UVM_HIGH)
    endfunction

    function void write_wb(wb_item item);
        wb_arr.push_back(item);
        `uvm_info(get_type_name(), "Push item to wb arr", UVM_HIGH)
    endfunction

    function void write_dc(decode_item item);
        dc_arr.push_back(item);
        `uvm_info(get_type_name(), "Push item to dc arr", UVM_HIGH)
    endfunction

    function void write_exe(exe_item item);
        exe_arr.push_back(item);
        `uvm_info(get_type_name(), "Push item to exe arr", UVM_HIGH)
    endfunction
endclass

class im_scoreboard extends base_scoreboard;
    `uvm_component_utils(im_scoreboard)

    // fetch_item fetch_packet;
    // wb_item wb_packet;
    // decode_item dc_packet;
    // exe_item exe_packet;
    int reg_mem[32];
    int d_mem[64];

    function new (string name = "im_scoreboard", uvm_component parent);
        super.new(name,parent);
        for (int i = 0;i < 32; i++) begin
            reg_mem[i] = i;
        end
        for (int i = 0; i < 64; i++) begin
            d_mem[i] = i%64;
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            wait(wb_arr.size()!=0 || exe_arr.size()!=0);
            if (wb_arr.size()!=0) begin
                stage = 1;
                fetch_packet = fetch_arr.pop_front();
                wb_packet    = wb_arr.pop_front();
                dc_packet    = dc_arr.pop_front();
                compare(fetch_packet, wb_packet, dc_packet, , stage);
                stage = 0;
            end else if (exe_arr.size()!=0) begin
                stage = 2;
                fetch_packet = fetch_arr.pop_front();
                exe_packet   = exe_arr.pop_front();
                dc_packet    = dc_arr.pop_front();
                compare(fetch_packet, , dc_packet, exe_packet, stage);
                stage = 0;
            end
        end
    endtask

    task compare(fetch_item fetch_packet, wb_item wb_packet = null, decode_item dc_packet = null, exe_item exe_packet = null, int stage);
        bit is_match = 1;
        logic [6:0] opcode;
        logic [4:0] e_rs1, e_rs2, e_rd;
        logic signed [11:0] e_imm;
        logic signed [31:0] signed_imm;
        logic signed [31:0] expected_result;
        logic [31:0] e_next_PC;
        logic [2:0] funct3;
        logic       funct7_5;
        int option = 0;
        logic       hazard = 0;
        opcode = fetch_packet.instruction[6:0];
        if (opcode == 7'b0110011 && stage == 2) begin // R-type -> BEQ
            fetch_packet_tmp = fetch_arr.pop_front();
            e_rd = fetch_packet.instruction[11:7];
            e_rs1 = fetch_packet.instruction[19:15];
            e_rs2 = fetch_packet.instruction[24:20];
            funct3   = fetch_packet.instruction[14:12];
            funct7_5 = fetch_packet.instruction[30];

            case ({funct7_5, funct3})
                4'b0_000: expected_result = reg_mem[e_rs1] + reg_mem[e_rs2]; // ADD
                4'b1_000: expected_result = reg_mem[e_rs1] - reg_mem[e_rs2]; // SUB
                4'b0_111: expected_result = reg_mem[e_rs1] & reg_mem[e_rs2]; // AND
                4'b0_110: expected_result = reg_mem[e_rs1] | reg_mem[e_rs2]; // OR
                4'b0_100: expected_result = reg_mem[e_rs1] ^ reg_mem[e_rs2]; // XOR
                default: begin
                    `uvm_error("FAIL", $sformatf("Unsupported R-type funct7/funct3: %b_%b", funct7_5, funct3))
                    is_match = 0;
                end
            endcase
            expected_result_hz = expected_result;
            e_rd_hz = e_rd;

            fetch_arr.push_front(fetch_packet);
            fetch_packet = fetch_packet_tmp;
            opcode = fetch_packet_tmp.instruction[6:0];
            dc_packet_tmp = dc_arr.pop_front();
            dc_arr.push_front(dc_packet);
            dc_packet = dc_packet_tmp;
        end else if (opcode == 7'b0010011 && stage == 2) begin // I-type -> BEQ
            fetch_packet_tmp = fetch_arr.pop_front();
            e_rd  = fetch_packet.instruction[11:7];
            e_rs1 = fetch_packet.instruction[19:15];
            e_imm = fetch_packet.instruction[31:20];
            funct3 = fetch_packet.instruction[14:12];

            signed_imm = {{20{e_imm[11]}}, e_imm};

            case(funct3)
                3'b000: expected_result = reg_mem[e_rs1] + signed_imm; // ADDI
                3'b111: expected_result = reg_mem[e_rs1] & signed_imm; // ANDI
                3'b110: expected_result = reg_mem[e_rs1] | signed_imm; // ORI
                3'b100: expected_result = reg_mem[e_rs1] ^ signed_imm; // XORI
                default: begin
                    `uvm_error("FAIL", $sformatf("Unsupported I-type funct3: %b", funct3))
                    is_match = 0;
                end
            endcase
            expected_result_hz = expected_result;
            e_rd_hz = e_rd;

            fetch_arr.push_front(fetch_packet);
            fetch_packet = fetch_packet_tmp;
            opcode = fetch_packet_tmp.instruction[6:0];
            dc_packet_tmp = dc_arr.pop_front();
            dc_arr.push_front(dc_packet);
            dc_packet = dc_packet_tmp;
        end
        case(opcode)
            // R-type
            7'b0110011: begin
                `uvm_info(get_type_name(), "Decoding R-type instruction", UVM_HIGH)
                e_rd = fetch_packet.instruction[11:7];
                e_rs1 = fetch_packet.instruction[19:15];
                e_rs2 = fetch_packet.instruction[24:20];
                funct3   = fetch_packet.instruction[14:12];
                funct7_5 = fetch_packet.instruction[30];

                case ({funct7_5, funct3})
                    4'b0_000: expected_result = reg_mem[e_rs1] + reg_mem[e_rs2]; // ADD
                    4'b1_000: expected_result = reg_mem[e_rs1] - reg_mem[e_rs2]; // SUB
                    4'b0_111: expected_result = reg_mem[e_rs1] & reg_mem[e_rs2]; // AND
                    4'b0_110: expected_result = reg_mem[e_rs1] | reg_mem[e_rs2]; // OR
                    4'b0_100: expected_result = reg_mem[e_rs1] ^ reg_mem[e_rs2]; // XOR
                    default: begin
                        `uvm_error("FAIL", $sformatf("Unsupported R-type funct7/funct3: %b_%b", funct7_5, funct3))
                        is_match = 0;
                    end
                endcase

                if (e_rd !== wb_packet.rd || 
                    e_rs1 !== dc_packet.rs1 ||
                    e_rs2 !== dc_packet.rs2 ||
                    expected_result !== wb_packet.result_W) begin
                    is_match = 0;
                end
                if (is_match) reg_mem[e_rd] = expected_result; 
            end
            // I-type
            7'b0010011: begin
                `uvm_info(get_type_name(), "Decoding I-type instruction", UVM_HIGH)
                e_rd  = fetch_packet.instruction[11:7];
                e_rs1 = fetch_packet.instruction[19:15];
                e_imm = fetch_packet.instruction[31:20];
                funct3 = fetch_packet.instruction[14:12];

                signed_imm = {{20{e_imm[11]}}, e_imm};

                case(funct3)
                    3'b000: expected_result = reg_mem[e_rs1] + signed_imm; // ADDI
                    3'b111: expected_result = reg_mem[e_rs1] & signed_imm; // ANDI
                    3'b110: expected_result = reg_mem[e_rs1] | signed_imm; // ORI
                    3'b100: expected_result = reg_mem[e_rs1] ^ signed_imm; // XORI
                    default: begin
                        `uvm_error("FAIL", $sformatf("Unsupported I-type funct3: %b", funct3))
                        is_match = 0;
                    end
                endcase
                if (e_rd !== wb_packet.rd || e_rs1 !== dc_packet.rs1 || expected_result !== wb_packet.result_W) begin
                    is_match = 0;
                end
                if (is_match) reg_mem[e_rd] = expected_result;
            end
            7'b1100011: begin
                logic signed [12:0] e_b_imm;
                logic signed [31:0] signed_b_imm;
                bit branch_taken;
                option = 1;

                `uvm_info(get_type_name(), "Decoding B-type instruction", UVM_HIGH)

                e_rs1 = fetch_packet.instruction[19:15];
                e_rs2 = fetch_packet.instruction[24:20];

                e_b_imm[12]   = fetch_packet.instruction[31];
                e_b_imm[11]   = fetch_packet.instruction[7];
                e_b_imm[10:5] = fetch_packet.instruction[30:25];
                e_b_imm[4:1]  = fetch_packet.instruction[11:8];
                e_b_imm[0]    = 1'b0;

                signed_b_imm = {{19{e_b_imm[12]}}, e_b_imm};

                if (e_rs1 == e_rd_hz) begin
                    `uvm_info("HAHA", $sformatf("rs1 hazard: e_rs1: %d, e_rd_hz: %d", e_rs1, e_rd_hz), UVM_LOW)
                    branch_taken = (expected_result_hz == reg_mem[e_rs2]);
                    expected_result_hz = -1;
                    e_rd_hz = -1;
                    hazard = 1;
                end else if (e_rs2 == e_rd_hz) begin
                    `uvm_info("HAHA", $sformatf("rs2 hazard: e_rs2: %d, e_rd_hz: %d", e_rs2, e_rd_hz), UVM_LOW)
                    branch_taken = (reg_mem[e_rs1] == expected_result_hz);
                    expected_result_hz = -1;
                    e_rd_hz = -1;
                    hazard = 1;
                end else branch_taken = (reg_mem[e_rs1] == reg_mem[e_rs2]);

                if (is_match) begin
                    if (branch_taken) begin
                        e_next_PC = fetch_packet.PC_o + signed_b_imm;
                    end else begin
                        e_next_PC = fetch_packet.PC_o + 12;
                    end

                    if (e_rs1 !== dc_packet.rs1 || 
                        e_rs2 !== dc_packet.rs2 || 
                        e_next_PC !== exe_packet.PC_F) begin
                        is_match = 0;
                    end
                    if (branch_taken) begin
                        // if (hazard) begin
                        //     while (dc_arr.size() > 1) begin
                        //         dc_packet = dc_arr.pop_back();
                        //     end
                        //     while (fetch_arr.size() > 1) begin
                        //         fetch_arr.pop_back();
                        //     end
                        // end else begin
                        //     while (dc_arr.size() > 0) begin
                        //         dc_packet = dc_arr.pop_back();
                        //     end
                        //     while (fetch_arr.size() > 0) begin
                        //         fetch_arr.pop_back();
                        //     end
                        // end
                        // if (dc_arr.size() > 0) begin
                        //     dc_packet = dc_arr.pop_back(); // actually also need to pop two from decode too, but at the moment
                        //                                 // this packet pass, only one dc_packet is available in the array, 
                        //                                 // therefore pop one in the monitor
                        // end
                        fetch_arr.pop_back();
                        fetch_arr.pop_back();
                        dc_arr.pop_back();
                    end
                end
            end
            7'b0000011: begin
                logic unsigned [31:0] e_addr;
                logic signed [31:0] e_load_data;
                `uvm_info(get_type_name(), "Decoding Load-type instruction (LW)", UVM_HIGH)

                e_rd  = fetch_packet.instruction[11:7];
                e_rs1 = fetch_packet.instruction[19:15];
                e_imm = fetch_packet.instruction[31:20];

                signed_imm = {{20{e_imm[11]}}, e_imm};

                e_addr = reg_mem[e_rs1] + signed_imm;

                e_load_data = d_mem[e_addr%64]; 

                if (e_rd != fetch_packet.rd ||
                    e_rs1 != fetch_packet.rs1 ||
                    e_addr != fetch_packet.ALU_o ||
                    e_load_data != fetch_packet.mem_data_o) begin
                    is_match = 0;
                end

                if (is_match) begin
                    reg_mem[e_rd] = e_load_data;
                end
            end
            7'b0100011: begin
                logic unsigned [31:0] e_addr;
                logic signed [31:0] e_store_data;
                `uvm_info(get_type_name(), "Decoding Store-type instruction (SW)", UVM_HIGH)
                
                e_rs1 = fetch_packet.instruction[19:15];
                e_rs2 = fetch_packet.instruction[24:20];
                e_imm = {fetch_packet.instruction[31:25], fetch_packet.instruction[11:7]};
                signed_imm = {{20{e_imm[11]}}, e_imm};

                e_addr = reg_mem[e_rs1] + signed_imm;
                e_store_data = reg_mem[e_rs2];

                if (e_rs1 != fetch_packet.rs1 ||
                    e_rs2 != fetch_packet.rs2 ||
                    e_addr != fetch_packet.ALU_o ||
                    e_store_data != fetch_packet.store_data_o) begin
                    is_match = 0;
                end

                if (is_match) begin
                    d_mem[e_addr % 64] = e_store_data;
                end
            end
            default: begin
                `uvm_error("FAIL", $sformatf("Unknown opcode 0x%h, skipping comparison", opcode))
                is_match = 0;
            end
        endcase
        if (is_match) begin
            `uvm_info($sformatf("%sPASS%s", `UVM_COLOR_PASS, `UVM_COLOR_RESET), $sformatf("SCOREBOARD: Item matched %h", fetch_packet.instruction), UVM_LOW)
        end else begin
            `uvm_error($sformatf("%sFAIL%s", `UVM_COLOR_FAIL, `UVM_COLOR_RESET), $sformatf("SCOREBOARD: Item mismatched %h", fetch_packet.instruction))
            if (!option) begin
                `uvm_info(get_type_name(), $sformatf("Mismatch details:\nDecoded Expected: opcode=0x%h, rd=%d, rs1=%d, rs2=%d, imm=%d, expected=%h\nActual Packet:\n%s",
                                         opcode, e_rd, e_rs1, e_rs2, e_imm, expected_result, wb_packet.sprint()), UVM_LOW)
            end else `uvm_info(get_type_name(), $sformatf("Mismatch details:\nDecoded Expected: opcode=0x%h, rd=%d, rs1=%d, rs2=%d, imm=%d, expected=%h\nActual Exe Packet:\n%s, Actual DC Packet: \n%s",
                                         opcode, e_rd, e_rs1, e_rs2, e_imm, e_next_PC, exe_packet.sprint(), dc_packet.sprint()), UVM_LOW)
        end
    endtask
endclass