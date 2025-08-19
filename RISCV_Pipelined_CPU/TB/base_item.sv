class base_item extends uvm_sequence_item;
    `uvm_object_utils(base_item)

    function new (string name = "base_item");
        super.new(name);
    endfunction
endclass

typedef enum {ADD, ADDI, SUB, AND, OR, XOR, ORI, XORI, ANDI, BEQ, BNE, JAL, LW, SW} inst_type_e;
class fetch_item extends base_item;

    rand inst_type_e    inst_type;
    rand logic [4:0]    rs1;
    rand logic [4:0]    rs2;
    rand logic [4:0]    rd;
    rand logic signed [11:0]   imm; // random value for addi
    rand logic signed [12:0] b_imm; // random value for beq
    rand logic signed [20:0] j_imm; // random value for jal

    logic [31:0]        instruction;
    logic [31:0]        PC_o;
    logic [31:0]        next_PC_o;
    logic signed [31:0] ALU_o;
    logic [31:0]        mem_data_o; // for jal 
    logic [31:0]        store_data_o; // for sw 

    // constraint c_build_instruction {
    //     solve inst_type before instruction;
    //     (inst_type == ADD) -> {
    //         instruction == {7'b0000000, rs2, rs1, 3'b000, rd, 7'b0110011};
    //         imm == 0;
    //     }
    //     (inst_type == ADDI) -> {
    //         instruction == {imm, rs1, 3'b000, rd, 7'b0010011};
    //         rs2 == 0;
    //     }
    //     (inst_type == SUB) -> {
    //         instruction == {7'b0100000, rs2, rs1, 3'b000, rd, 7'b0110011};
    //         imm == 0;
    //     }
    //     (inst_type == AND) -> {
    //         instruction == {7'b0000000, rs2, rs1, 3'b111, rd, 7'b0110011};
    //         imm == 0;
    //     }
    //     (inst_type == OR) -> {
    //         instruction == {7'b0000000, rs2, rs1, 3'b110, rd, 7'b0110011};
    //         imm == 0;
    //     }
    //     (inst_type == XOR) -> {
    //         instruction == {7'b0000000, rs2, rs1, 3'b100, rd, 7'b0110011};
    //         imm == 0;
    //     }
    //     (inst_type == ORI) -> {
    //         instruction == {imm, rs1, 3'b110, rd, 7'b0010011};
    //         rs2 == 0;
    //     }
    //     (inst_type == XORI) -> {
    //         instruction == {imm, rs1, 3'b100, rd, 7'b0010011};
    //         rs2 == 0;
    //     }
    //     (inst_type == ANDI) -> {
    //         instruction == {imm, rs1, 3'b111, rd, 7'b0010011};
    //         rs2 == 0;
    //     }
    //     (inst_type == BEQ) -> {
    //         instruction == {b_imm[12], b_imm[10:5], rs2, rs1, 3'b000, b_imm[4:1], b_imm[11], 7'b1100011};
    //         rd == 0; imm == 0;
    //     }
    //     (inst_type == BNE) -> {
    //         instruction == {b_imm[12], b_imm[10:5], rs2, rs1, 3'b001, b_imm[4:1], b_imm[11], 7'b1100011};
    //         rd == 0; imm == 0;
    //     }
    //     (inst_type == JAL) -> {
    //         instruction == {j_imm[20], j_imm[10:1], j_imm[11], j_imm[19:12], rd, 7'b1101111};
    //         rs1 == 0; rs2 == 0; imm == 0; b_imm == 0;
    //     }
    //     (inst_type == LW) -> {
    //         instruction == {imm, rs1, 3'b000, rd, 7'b0000011};
    //         rs2 == 0; b_imm == 0; j_imm == 0;
    //     }
    //     (inst_type == SW) -> {
    //         instruction == {imm[11:5], rs2, rs1, 3'b000, imm[4:0], 7'b0100011};
    //         rd == 0; b_imm == 0; j_imm == 0;
    //     }
    // }

    constraint c_valid_fields {
        // Ràng buộc các giá trị không sử dụng để chúng không ảnh hưởng đến các lệnh khác
        (inst_type inside {ADD, SUB, AND, OR, XOR}) -> { imm == 0; b_imm == 0; j_imm == 0; }
        (inst_type inside {ADDI, ORI, XORI, ANDI, LW}) -> { rs2 == 0; b_imm == 0; j_imm == 0; }
        (inst_type inside {BEQ, BNE}) -> { rd == 0; imm == 0; j_imm == 0; }
        (inst_type == JAL) -> { rs1 == 0; rs2 == 0; imm == 0; b_imm == 0; }
        (inst_type == SW) -> { rd == 0; b_imm == 0; j_imm == 0; }
    }

    constraint c_branch_alignment {
        b_imm[1:0] == 2'b00;
    }

    // constraint c_valid_rd {
    //     (inst_type inside {ADD, ADDI, SUB, AND, OR, XOR, ORI, XORI, ANDI, JAL}) -> rd != 0;
    // }

    function void post_randomize();
    case (inst_type)
        ADD:  instruction = {7'b0000000, rs2, rs1, 3'b000, rd, 7'b0110011};
        ADDI: instruction = {imm, rs1, 3'b000, rd, 7'b0010011};
        SUB:  instruction = {7'b0100000, rs2, rs1, 3'b000, rd, 7'b0110011};
        AND:  instruction = {7'b0000000, rs2, rs1, 3'b111, rd, 7'b0110011};
        OR:   instruction = {7'b0000000, rs2, rs1, 3'b110, rd, 7'b0110011};
        XOR:  instruction = {7'b0000000, rs2, rs1, 3'b100, rd, 7'b0110011};
        ORI:  instruction = {imm, rs1, 3'b110, rd, 7'b0010011};
        XORI: instruction = {imm, rs1, 3'b100, rd, 7'b0010011};
        ANDI: instruction = {imm, rs1, 3'b111, rd, 7'b0010011};
        BEQ:  instruction = {b_imm[12], b_imm[10:5], rs2, rs1, 3'b000, b_imm[4:1], b_imm[11], 7'b1100011};
        BNE:  instruction = {b_imm[12], b_imm[10:5], rs2, rs1, 3'b001, b_imm[4:1], b_imm[11], 7'b1100011};
        JAL:  instruction = {j_imm[20], j_imm[10:1], j_imm[11], j_imm[19:12], rd, 7'b1101111};
        LW:   instruction = {imm, rs1, 3'b000, rd, 7'b0000011};
        SW:   instruction = {imm[11:5], rs2, rs1, 3'b000, imm[4:0], 7'b0100011};
        default: `uvm_fatal("POST_RAND", "Unknown inst_type in post_randomize")
    endcase
endfunction
    
    `uvm_object_utils_begin(fetch_item)
        `uvm_field_enum(inst_type_e, inst_type, UVM_ALL_ON)
        `uvm_field_int(rs1, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(rs2, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(rd, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(imm, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(b_imm, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(j_imm, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(ALU_o, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(mem_data_o, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(store_data_o, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(instruction, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(PC_o, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(next_PC_o, UVM_ALL_ON | UVM_HEX)
    `uvm_object_utils_end

    function new (string name = "fetch_item");
        super.new(name);
    endfunction
endclass

class wb_item extends base_item;
    
    logic   [31:0]  result_W;
    logic   [4:0]   rd;
    logic           RegWrite;

    `uvm_object_utils_begin(wb_item)
        `uvm_field_int(rd, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(result_W, UVM_ALL_ON | UVM_HEX)
    `uvm_object_utils_end
    function new (string name = "wb_item");
        super.new(name);
    endfunction
endclass

class decode_item extends base_item;
    logic   [4:0]   rs1;
    logic   [4:0]   rs2;

    `uvm_object_utils_begin(decode_item)
        `uvm_field_int(rs1, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(rs2, UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end
    function new (string name = "decode_item");
        super.new(name);
    endfunction
endclass

class reset_item extends base_item;
    rand logic rst_n;
    `uvm_object_utils_begin(reset_item)
        `uvm_field_int(rst_n, UVM_ALL_ON)
    `uvm_object_utils_end
    function new (string name = "reset_item");
        super.new(name);
    endfunction
endclass