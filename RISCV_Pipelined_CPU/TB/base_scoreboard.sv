`define UVM_COLOR_PASS "\033[0;32m" // Green
`define UVM_COLOR_FAIL "\033[0;31m" // Red
`define UVM_COLOR_RESET "\033[0m"   // Reset to default color

`uvm_analysis_imp_decl(_fetch) 
`uvm_analysis_imp_decl(_wb)    
`uvm_analysis_imp_decl(_dc)    

class base_scoreboard #(type T = uvm_sequence_item) extends uvm_scoreboard;
    `uvm_component_utils(base_scoreboard)

    uvm_analysis_imp_fetch #(fetch_item, base_scoreboard) fetch_imp;
    uvm_analysis_imp_wb #(wb_item, base_scoreboard) wb_imp;
    uvm_analysis_imp_dc #(decode_item, base_scoreboard) dc_imp;

    fetch_item fetch_arr[$];
    wb_item wb_arr[$];
    decode_item dc_arr[$];

    function new (string name = "base_scoreboard", uvm_component parent);
        super.new(name,parent);
        fetch_imp = new("fetch_imp", this);
        wb_imp = new("wb_imp", this);
        dc_imp = new("dc_imp", this);
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
endclass

class im_scoreboard extends base_scoreboard;
    `uvm_component_utils(im_scoreboard)

    fetch_item fetch_packet;
    wb_item wb_packet;
    decode_item dc_packet;
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
            wait(wb_arr.size()!=0);
            fetch_packet = fetch_arr.pop_front();
            wb_packet    = wb_arr.pop_front();
            dc_packet    = dc_arr.pop_front();
            compare(fetch_packet, wb_packet, dc_packet);
        end
    endtask

    task compare(fetch_item fetch_packet, wb_item wb_packet, decode_item dc_packet);
        bit is_match = 1;
        logic [6:0] opcode;
        logic [4:0] e_rs1, e_rs2, e_rd;
        logic signed [11:0] e_imm;
        logic signed [31:0] signed_imm;
        logic signed [31:0] expected_result;
        logic [2:0] funct3;
        opcode = fetch_packet.instruction[6:0];
        case(opcode)
            // R-type
            7'b0110011: begin
                logic       funct7_5;
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
                if (e_rd != fetch_packet.rd || e_rs1 != fetch_packet.rs1 || expected_result != fetch_packet.ALU_o) begin
                    is_match = 0;
                end
                if (is_match) reg_mem[e_rd] = expected_result;
            end
            7'b1100011: begin
                logic signed [12:0] e_b_imm;
                logic signed [31:0] signed_b_imm;
                logic [31:0] e_next_PC;
                bit branch_taken;

                `uvm_info(get_type_name(), "Decoding B-type instruction", UVM_HIGH)

                e_rs1 = fetch_packet.instruction[19:15];
                e_rs2 = fetch_packet.instruction[24:20];

                e_b_imm[12]   = fetch_packet.instruction[31];
                e_b_imm[11]   = fetch_packet.instruction[7];
                e_b_imm[10:5] = fetch_packet.instruction[30:25];
                e_b_imm[4:1]  = fetch_packet.instruction[11:8];
                e_b_imm[0]    = 1'b0;

                signed_b_imm = {{19{e_b_imm[12]}}, e_b_imm};
                funct3 = fetch_packet.instruction[14:12];
                case (funct3)
                    3'b000: // BEQ
                        branch_taken = (reg_mem[e_rs1] == reg_mem[e_rs2]);
                    3'b001: // BNE
                        branch_taken = (reg_mem[e_rs1] != reg_mem[e_rs2]);
                    default: begin
                        `uvm_error("FAIL", $sformatf("Unsupported B-type funct3: %b", funct3))
                        is_match = 0;
                    end
                endcase

                if (is_match) begin
                    if (branch_taken) begin
                        e_next_PC = fetch_packet.PC_o + signed_b_imm;
                    end else begin
                        e_next_PC = fetch_packet.PC_o + 4;
                    end

                    if (e_rs1 != fetch_packet.rs1 || 
                        e_rs2 != fetch_packet.rs2 || 
                        e_next_PC != fetch_packet.next_PC_o) begin
                        is_match = 0;
                    end
                end
            end
            7'b1101111: begin
                logic signed [20:0] e_j_imm;
                logic signed [31:0] signed_j_imm;
                logic [31:0] e_next_PC;
                logic [31:0] e_link_addr; // PC+4

                `uvm_info(get_type_name(), "Decoding J-type instruction", UVM_HIGH)
                
                e_rd = fetch_packet.instruction[11:7];
                
                e_j_imm[20]    = fetch_packet.instruction[31];
                e_j_imm[19:12] = fetch_packet.instruction[19:12];
                e_j_imm[11]    = fetch_packet.instruction[20];
                e_j_imm[10:1]  = fetch_packet.instruction[30:21];
                e_j_imm[0]     = 1'b0;

                signed_j_imm = {{11{e_j_imm[20]}}, e_j_imm};

                e_next_PC = fetch_packet.PC_o + signed_j_imm;
                e_link_addr = fetch_packet.PC_o + 4;
                if (e_rd != fetch_packet.rd || 
                    e_next_PC != fetch_packet.next_PC_o ||
                    e_link_addr != fetch_packet.mem_data_o) begin // So sánh giá trị ghi lại
                    is_match = 0;
                    // `uvm_info(get_type_name(), $sformatf("JAL Mismatch Details:\n"
                    //     , "\t- RD Addr:   exp=%0d, act=%0d\n", e_rd, fetch_packet.rd
                    //     , "\t- Next PC:   exp=0x%h, act=0x%h\n", e_next_PC, fetch_packet.next_PC_o
                    //     , "\t- Link Addr: exp=0x%h, act=0x%h", e_link_addr, fetch_packet.reg_mem_data_o), UVM_LOW)
                end
                
                if (is_match) begin
                    reg_mem[e_rd] = e_link_addr;
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
                // $display(e_load_data, e_addr);

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
            `uvm_info($sformatf("%sPASS%s", `UVM_COLOR_PASS, `UVM_COLOR_RESET), "SCOREBOARD: Item matched", UVM_LOW)
        end else begin
            `uvm_error($sformatf("%sFAIL%s", `UVM_COLOR_FAIL, `UVM_COLOR_RESET), "SCOREBOARD: Item mismatch")
            `uvm_info(get_type_name(), $sformatf("Mismatch details:\nDecoded Expected: opcode=0x%h, rd=%d, rs1=%d, rs2=%d, imm=%d\nActual Packet:\n%s",
                                         opcode, e_rd, e_rs1, e_rs2, e_imm, fetch_packet.sprint()), UVM_LOW)
        end
    endtask
endclass