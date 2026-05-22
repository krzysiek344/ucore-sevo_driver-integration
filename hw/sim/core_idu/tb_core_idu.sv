/* Copyright (C) 2025  AGH University of Krakow */

module tb_core_idu
    import core_pkg::*;
;


/* Local variables and signals */

instr_t      instr;
logic [31:0] ibus_rdata, imm;
logic [4:0]  rs1, rs2, rd;
logic        ibus_rvalid, instr_valid;


/* Submodules placement */

idu dut (
    .ibus_rvalid,
    .ibus_rdata,

    .instr_valid,
    .instr,
    .imm,
    .rs1,
    .rs2,
    .rd
);


/* Tasks and functions definitions */

task test_instructions_validity();
    for (int i = 0; i < 2; ++i) begin
        ibus_rvalid = i;

        #1;
        assert (instr_valid == ibus_rvalid) else
            $error("instr_valid: exp: %b, rcv: %b", ibus_rvalid, instr_valid);
    end
endtask

task test_r_type_instructions();
    static instr_t instructions[$] = {ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND};

    foreach (instructions[i]) begin
        ibus_rdata[31:25] = instructions[i][16:10];     /* funct7 */
        ibus_rdata[24:20] = $random();                  /* rs2 */
        ibus_rdata[19:15] = $random();                  /* rs1 */
        ibus_rdata[14:12] = instructions[i][9:7];       /* funct3 */
        ibus_rdata[11:7] = $random();                   /* rd */
        ibus_rdata[6:0] = instructions[i][6:0];         /* opcode */

        #1;
        assert (instr == instructions[i]) else
            $error("instr: %s: instr: exp: %s, rcv: %s",
                instructions[i].name, instructions[i].name, instr.name);

        assert ((rs1 == ibus_rdata[19:15]) && (rs2 == ibus_rdata[24:20]) && (rd == ibus_rdata[11:7])) else
            $error("instr: %s: rs1: exp: %x, rcv: %x; rs2: exp: %x, rcv: %x; rd: exp: %x, rcv: %x",
                instructions[i].name, ibus_rdata[19:15], rs1, ibus_rdata[24:20], rs2, ibus_rdata[11:7], rd);
    end
endtask

task test_i_type_instructions();
    static instr_t instructions[$] = {
        JALR, LB, LH, LW, LBU, LHU, ADDI, SLTI, SLTIU, XORI, ORI, ANDI
    };

    foreach (instructions[i]) begin
        ibus_rdata[31:20] = $random();              /* imm[11:0] */
        ibus_rdata[19:15] = $random();              /* rs1 */
        ibus_rdata[14:12] = instructions[i][9:7];   /* funct3 */
        ibus_rdata[11:7] = $random();               /* rd */
        ibus_rdata[6:0] = instructions[i][6:0];     /* opcode */

        #1;
        assert (instr == instructions[i]) else
            $error("instr: %s: instr: exp: %s, rcv: %s",
                instructions[i].name, instructions[i].name, instr.name);

        assert (imm == {{20{ibus_rdata[31]}}, ibus_rdata[31:20]}) else
            $error("instr: %s: imm: exp: %x, rcv: %x",
                instructions[i].name, {{20{ibus_rdata[31]}}, ibus_rdata[31:20]}, imm);

        assert ((rs1 == ibus_rdata[19:15]) && (rd == ibus_rdata[11:7])) else
            $error("instr: %s: rs1: exp: %x, rcv: %x; rd: exp: %x, rcv: %x",
                instructions[i].name, ibus_rdata[19:15], rs1, ibus_rdata[11:7], rd);
    end
endtask

task test_i_type_shift_instructions();
    static instr_t instructions[$] = {SLLI, SRLI, SRAI};

    foreach (instructions[i]) begin
        ibus_rdata[31:25] = instructions[i][16:10];     /* funct7 */
        ibus_rdata[24:20] = $random();                  /* shamt */
        ibus_rdata[19:15] = $random();                  /* rs1 */
        ibus_rdata[14:12] = instructions[i][9:7];       /* funct3 */
        ibus_rdata[11:7] = $random();                   /* rd */
        ibus_rdata[6:0] = instructions[i][6:0];         /* opcode */

        #1;
        assert (instr == instructions[i]) else
            $error("instr: %s: instr: exp: %s, rcv: %s",
                instructions[i].name, instructions[i].name, instr.name);

        assert (imm == {{20{ibus_rdata[31]}}, ibus_rdata[31:20]}) else
            $error("instr: %s: imm: exp: %x, rcv: %x",
                instructions[i].name, {{20{ibus_rdata[31]}}, ibus_rdata[31:20]}, imm);

        assert ((rs1 == ibus_rdata[19:15]) && (rd == ibus_rdata[11:7])) else
            $error("instr: %s: rs1: exp: %x, rcv: %x; rd: exp: %x, rcv: %x",
                instructions[i].name, ibus_rdata[19:15], rs1, ibus_rdata[11:7], rd);
    end
endtask

task test_s_type_instructions();
    static instr_t instructions[$] = {SB, SH, SW};

    foreach (instructions[i]) begin
        ibus_rdata[31:25] = $random();              /* imm[11:5] */
        ibus_rdata[24:20] = $random();              /* rs2 */
        ibus_rdata[19:15] = $random();              /* rs1 */
        ibus_rdata[14:12] = instructions[i][9:7];   /* funct3 */
        ibus_rdata[11:7] = $random();               /* imm[4:0] */
        ibus_rdata[6:0] = instructions[i][6:0];     /* opcode */

        #1;
        assert (instr == instructions[i]) else
            $error("instr: %s: instr: exp: %s, rcv: %s",
                instructions[i].name, instructions[i].name, instr.name);

        assert (imm == {{20{ibus_rdata[31]}}, ibus_rdata[31:25], ibus_rdata[11:7]}) else
            $error("instr: %s: imm: exp: %x, rcv: %x",
                instructions[i].name, {{20{ibus_rdata[31]}}, ibus_rdata[31:25], ibus_rdata[11:7]}, imm);

        assert ((rs1 == ibus_rdata[19:15]) && (rs2 == ibus_rdata[24:20])) else
            $error("instr: %s: rs1: exp: %x, rcv: %x; rs2: exp: %x, rcv: %x",
                instructions[i].name, ibus_rdata[19:15], rs1, ibus_rdata[24:20], rs2);
    end
endtask

task test_b_type_instructions();
    static instr_t instructions[$] = {BEQ, BNE, BLT, BGE, BLTU, BGEU};

    foreach (instructions[i]) begin
        ibus_rdata[31] = $random();                 /* imm[12] */
        ibus_rdata[30:25] = $random();              /* imm[10:5] */
        ibus_rdata[24:20] = $random();              /* rs2 */
        ibus_rdata[19:15] = $random();              /* rs1 */
        ibus_rdata[14:12] = instructions[i][9:7];   /* funct3 */
        ibus_rdata[11:8] = $random();               /* imm[4:1] */
        ibus_rdata[7] = $random();                  /* imm[11] */
        ibus_rdata[6:0] = instructions[i][6:0];     /* opcode */

        #1;
        assert (instr == instructions[i]) else
            $error("instr: %s: instr: exp: %s, rcv: %s",
                instructions[i].name, instructions[i].name, instr.name);

        assert (imm == {{19{ibus_rdata[31]}}, ibus_rdata[31], ibus_rdata[7], ibus_rdata[30:25], ibus_rdata[11:8], 1'b0}) else
            $error("instr: %s: imm: exp: %x, rcv: %x",
                instructions[i].name, {{19{ibus_rdata[31]}}, ibus_rdata[31], ibus_rdata[7], ibus_rdata[30:25], ibus_rdata[11:8], 1'b0}, imm);

        assert ((rs1 == ibus_rdata[19:15]) && (rs2 == ibus_rdata[24:20])) else
            $error("instr: %s: rs1: exp: %x, rcv: %x; rs2: exp: %x, rcv: %x",
                instructions[i].name, ibus_rdata[19:15], rs1, ibus_rdata[24:20], rs2);
    end
endtask

task test_u_type_instructions();
    static instr_t instructions[$] = {LUI, AUIPC};

    foreach (instructions[i]) begin
        ibus_rdata[31:12] = $random();              /* imm[31:12] */
        ibus_rdata[11:7] = $random();               /* rd */
        ibus_rdata[6:0] = instructions[i][6:0];     /* opcode */

        #1;
        assert (instr == instructions[i]) else
            $error("instr: %s: instr: exp: %s, rcv: %s",
                instructions[i].name, instructions[i].name, instr.name);

        assert (imm == {ibus_rdata[31:12], 12'b0}) else
            $error("instr: %s: imm: exp: %x, rcv: %x",
                instructions[i].name, {ibus_rdata[31:12], 12'b0}, imm);

        assert (rd == ibus_rdata[11:7]) else
            $error("instr: %s: rd: exp: %x, rcv: %x",
                instructions[i].name, ibus_rdata[11:7], rd);
    end
endtask

task test_j_type_instructions();
    static instr_t instructions[$] = {JAL};

    foreach (instructions[i]) begin
        ibus_rdata[31] = $random();                 /* imm[20] */
        ibus_rdata[30:21] = $random();              /* imm[10:1] */
        ibus_rdata[20] = $random();                 /* imm[11] */
        ibus_rdata[19:12] = $random();              /* imm[19:12] */
        ibus_rdata[11:7] = $random();               /* rd */
        ibus_rdata[6:0] = instructions[i][6:0];     /* opcode */

        #1;
        assert (instr == instructions[i]) else
            $error("instr: %s: instr: exp: %s, rcv: %s",
                instructions[i].name, instructions[i].name, instr.name);

        assert (imm == {{12{ibus_rdata[31]}}, ibus_rdata[19:12], ibus_rdata[20], ibus_rdata[30:21], 1'b0}) else
            $error("instr: %s: imm: exp: %x, rcv: %x",
                instructions[i].name, {{12{ibus_rdata[31]}}, ibus_rdata[19:12], ibus_rdata[20], ibus_rdata[30:21], 1'b0}, imm);

        assert (rd == ibus_rdata[11:7]) else
            $error("instr: %s: rd: exp: %x, rcv: %x",
                instructions[i].name, ibus_rdata[11:7], rd);
    end
endtask


/* Test */

initial begin
    ibus_rvalid = 1'b0;
    ibus_rdata = 32'b0;

    for (int i = 0; i < 100; ++i) begin
        test_instructions_validity();
        test_r_type_instructions();
        test_i_type_instructions();
        test_i_type_shift_instructions();
        test_s_type_instructions();
        test_b_type_instructions();
        test_u_type_instructions();
        test_j_type_instructions();
    end

    $finish;
end

endmodule
