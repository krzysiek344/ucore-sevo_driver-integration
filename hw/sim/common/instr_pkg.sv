/* Copyright (C) 2025  AGH University of Krakow */

package instr_pkg;


/* User defined types */

typedef struct {
    logic [6:0] funct7;
    logic [2:0] funct3;
    logic [6:0] opcode;
} r_type_instr_code_t;

typedef struct {
    logic [2:0] funct3;
    logic [6:0] opcode;
} i_type_instr_code_t;

typedef struct {
    logic [2:0] funct3;
    logic [6:0] opcode;
} s_type_instr_code_t;

typedef struct {
    logic [2:0] funct3;
    logic [6:0] opcode;
} b_type_instr_code_t;

typedef struct {
    logic [6:0] opcode;
} u_type_instr_code_t;

typedef struct {
    logic [6:0] opcode;
} j_type_instr_code_t;


/* Constants */

const r_type_instr_code_t ADD_CODE = '{funct7: 7'b0000000, funct3: 3'b000, opcode: 7'b0110011};
const r_type_instr_code_t SUB_CODE = '{funct7: 7'b0100000, funct3: 3'b000, opcode: 7'b0110011};
const r_type_instr_code_t SLL_CODE = '{funct7: 7'b0000000, funct3: 3'b001, opcode: 7'b0110011};
const r_type_instr_code_t SLT_CODE = '{funct7: 7'b0000000, funct3: 3'b010, opcode: 7'b0110011};
const r_type_instr_code_t SLTU_CODE = '{funct7: 7'b0000000, funct3: 3'b011, opcode: 7'b0110011};
const r_type_instr_code_t XOR_CODE = '{funct7: 7'b0000000, funct3: 3'b100, opcode : 7'b0110011};
const r_type_instr_code_t SRL_CODE = '{funct7: 7'b0000000, funct3: 3'b101, opcode: 7'b0110011};
const r_type_instr_code_t SRA_CODE = '{funct7: 7'b0100000, funct3: 3'b101, opcode: 7'b0110011};
const r_type_instr_code_t OR_CODE = '{funct7: 7'b0000000, funct3: 3'b110, opcode: 7'b0110011};
const r_type_instr_code_t AND_CODE = '{funct7: 7'b0000000, funct3: 3'b111, opcode: 7'b0110011};

const i_type_instr_code_t JALR_CODE = '{funct3: 3'b000, opcode: 7'b1100111};
const i_type_instr_code_t LB_CODE = '{funct3: 3'b000, opcode: 7'b0000011};
const i_type_instr_code_t LH_CODE = '{funct3: 3'b001, opcode: 7'b0000011};
const i_type_instr_code_t LW_CODE = '{funct3: 3'b010, opcode: 7'b0000011};
const i_type_instr_code_t LBU_CODE = '{funct3: 3'b100, opcode: 7'b0000011};
const i_type_instr_code_t LHU_CODE = '{funct3: 3'b101, opcode: 7'b0000011};
const i_type_instr_code_t ADDI_CODE = '{funct3: 3'b000, opcode: 7'b0010011};
const i_type_instr_code_t SLTI_CODE = '{funct3: 3'b010, opcode: 7'b0010011};
const i_type_instr_code_t SLTIU_CODE = '{funct3: 3'b011, opcode: 7'b0010011};
const i_type_instr_code_t XORI_CODE = '{funct3: 3'b100, opcode: 7'b0010011};
const i_type_instr_code_t ORI_CODE = '{funct3: 3'b110, opcode: 7'b0010011};
const i_type_instr_code_t ANDI_CODE = '{funct3: 3'b111, opcode: 7'b0010011};
const i_type_instr_code_t SLLI_CODE = '{funct3: 3'b001, opcode: 7'b0010011};
const i_type_instr_code_t SRLI_CODE = '{funct3: 3'b101, opcode: 7'b0010011};
const i_type_instr_code_t SRAI_CODE = '{funct3: 3'b101, opcode: 7'b0010011};

const s_type_instr_code_t SB_CODE = '{funct3: 3'b000, opcode: 7'b0100011};
const s_type_instr_code_t SH_CODE = '{funct3: 3'b001, opcode: 7'b0100011};
const s_type_instr_code_t SW_CODE = '{funct3: 3'b010, opcode: 7'b0100011};

const b_type_instr_code_t BEQ_CODE = '{funct3: 3'b000, opcode: 7'b1100011};
const b_type_instr_code_t BNE_CODE = '{funct3: 3'b001, opcode: 7'b1100011};
const b_type_instr_code_t BLT_CODE = '{funct3: 3'b100, opcode: 7'b1100011};
const b_type_instr_code_t BGE_CODE = '{funct3: 3'b101, opcode: 7'b1100011};
const b_type_instr_code_t BLTU_CODE = '{funct3: 3'b110, opcode: 7'b1100011};
const b_type_instr_code_t BGEU_CODE = '{funct3: 3'b111, opcode: 7'b1100011};

const u_type_instr_code_t LUI_CODE = '{opcode: 7'b0110111};
const u_type_instr_code_t AUIPC_CODE = '{opcode: 7'b0010111};

const j_type_instr_code_t JAL_CODE = '{opcode: 7'b1101111};


/* Functions */

function logic [31:0] get_r_type_instruction(r_type_instr_code_t code, logic [4:0] rd,
    logic [4:0] rs1, logic [4:0] rs2);
    return {code.funct7, rs2, rs1, code.funct3, rd, code.opcode};
endfunction

function logic [31:0] get_i_type_instruction(i_type_instr_code_t code, logic [4:0] rd,
    logic [4:0] rs1, logic [11:0] imm);
    return {imm, rs1, code.funct3, rd, code.opcode};
endfunction

function logic [31:0] get_s_type_instruction(s_type_instr_code_t code, logic [4:0] rs1,
    logic [4:0] rs2, logic [11:0] imm);
    return {imm[11:5], rs2, rs1, code.funct3, imm[4:0], code.opcode};
endfunction

function logic [31:0] get_b_type_instruction(b_type_instr_code_t code, logic [4:0] rs1,
    logic [4:0] rs2, logic [12:0] imm);
    return {imm[12], imm[10:5], rs2, rs1, code.funct3, imm[4:1], imm[11], code.opcode};
endfunction

function logic [31:0] get_u_type_instruction(u_type_instr_code_t code, logic [4:0] rd,
    logic [31:0] imm);
    return {imm[31:12], rd, code.opcode};
endfunction

function logic [31:0] get_j_type_instruction(j_type_instr_code_t code, logic [4:0] rd,
    logic [20:0] imm);
    return {imm[20], imm[10:1], imm[11], imm[19:12], rd, code.opcode};
endfunction

function logic [31:0] get_nop_instruction();
    return get_i_type_instruction(ADDI_CODE, 0, 0, 0);
endfunction

endpackage
