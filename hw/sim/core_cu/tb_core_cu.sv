/* Copyright (C) 2025  AGH University of Krakow */

module tb_core_cu
    import core_pkg::*;
;


/* Local variables and signals */

logic       clk, rst_n;

instr_t     instr;

logic       ifu_branch, ifu_relative_jump, ifu_absolute_jump, ifu_stall, instr_valid;

rf_rd_src_t rf_rd_src;
logic       rf_we;

alu_op_t    alu_op;
alu_a_src_t alu_a_src;
alu_b_src_t alu_b_src;
logic       alu_eq, alu_lt;

lsu_op_t    lsu_op;
logic       lsu_done;


/* BFMs instantiation */

clk_gen #(
    .FREQUENCY_MHZ(50)
) u_clk_gen (
    .clk
);

rst_n_gen u_rst_n_gen (
    .rst_n,
    .clk
);


/* Submodules placement */

cu dut (
    .clk,
    .rst_n,

    .instr_valid,
    .instr,

    .ifu_branch,
    .ifu_relative_jump,
    .ifu_absolute_jump,
    .ifu_stall,

    .rf_we,
    .rf_rd_src,

    .alu_op,
    .alu_a_src,
    .alu_b_src,
    .alu_eq,
    .alu_lt,

    .lsu_op,
    .lsu_done
);


/* Tasks and functions definitions */

task test_alu_op();
    instr_t instruction;
    instruction = instruction.first();

    do begin
        instr = instruction;
        #1;

        if (instruction inside {ADD, ADDI, LB, LH, LW, LBU, LHU, SB, SH, SW, JAL, JALR, AUIPC}) begin
            assert (alu_op == ALU_OP_ADD) else
                $error("instruction: %s: alu_op: exp: %s, rcv: %s",
                    instruction.name, "ALU_OP_ADD", alu_op.name);
        end else if (instruction inside {SLT, SLTI, BLT, BGE}) begin
            assert (alu_op == ALU_OP_SLT) else
                $error("instruction: %s: alu_op: exp: %s, rcv: %s",
                    instruction.name, "ALU_OP_SLT", alu_op.name);
        end else if (instruction inside {SLTU, SLTIU, BLTU, BGEU}) begin
            assert (alu_op == ALU_OP_SLTU) else
                $error("instruction: %s: alu_op: exp: %s, rcv: %s",
                    instruction.name, "ALU_OP_SLTU", alu_op.name);
        end else if (instruction inside {AND, ANDI}) begin
            assert (alu_op == ALU_OP_AND) else
                $error("instruction: %s: alu_op: exp: %s, rcv: %s",
                    instruction.name, "ALU_OP_AND", alu_op.name);
        end else if (instruction inside {OR, ORI}) begin
            assert (alu_op == ALU_OP_OR) else
                $error("instruction: %s: alu_op: exp: %s, rcv: %s",
                    instruction.name, "ALU_OP_OR", alu_op.name);
        end else if (instruction inside {XOR, XORI}) begin
            assert (alu_op == ALU_OP_XOR) else
                $error("instruction: %s: alu_op: exp: %s, rcv: %s",
                    instruction.name, "ALU_OP_XOR", alu_op.name);
        end else if (instruction inside {SLL, SLLI}) begin
            assert (alu_op == ALU_OP_SLL) else
                $error("instruction: %s: alu_op: exp: %s, rcv: %s",
                    instruction.name, "ALU_OP_SLL", alu_op.name);
        end else if (instruction inside {SRL, SRLI}) begin
            assert (alu_op == ALU_OP_SRL) else
                $error("instruction: %s: alu_op: exp: %s, rcv: %s",
                    instruction.name, "ALU_OP_SRL", alu_op.name);
        end else if (instruction inside {SUB, BEQ, BNE}) begin
            assert (alu_op == ALU_OP_SUB) else
                $error("instruction: %s: alu_op: exp: %s, rcv: %s",
                    instruction.name, "ALU_OP_SUB", alu_op.name);
        end else if (instruction inside {SRA, SRAI}) begin
            assert (alu_op == ALU_OP_SRA) else
                $error("instruction: %s: alu_op: exp: %s, rcv: %s",
                    instruction.name, "ALU_OP_SRA", alu_op.name);
        end else begin
            assert (alu_op == ALU_OP_INVALID) else
                $error("instruction: %s: alu_a_src: exp: %s, rcv: %s",
                    instruction.name, "ALU_OP_INVALID", alu_a_src.name);
        end

        instruction = instruction.next();
    end while (instruction != instruction.last());
endtask

task test_alu_a_src();
    instr_t instruction;
    instruction = instruction.first();

    do begin
        instr = instruction;
        #1;

        if (instruction inside {AUIPC, JAL, JALR}) begin
            assert (alu_a_src == ALU_A_PC) else
                $error("instruction: %s: alu_a_src: exp: %s, rcv: %s",
                    instruction.name, "ALU_A_PC", alu_a_src.name);
        end else begin
            assert (alu_a_src == ALU_A_RF) else
                $error("instruction: %s: alu_a_src: exp: %s, rcv: %s",
                    instruction.name, "ALU_A_RF", alu_a_src.name);
        end

        instruction = instruction.next();
    end while (instruction != instruction.last());
endtask

task test_alu_b_src();
    instr_t instruction;
    instruction = instruction.first();

    do begin
        instr = instruction;
        #1;

        if (instruction inside {AUIPC, LB, LH, LW, LBU, LHU, SB, SH, SW,
            ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI}) begin
            assert (alu_b_src == ALU_B_IMM) else
                $error("instruction: %s: alu_b_src: exp: %s, rcv: %s",
                    instruction.name, "ALU_B_IMM", alu_b_src.name);
        end else if (instruction inside {JAL, JALR}) begin
            assert (alu_b_src == ALU_B_CONST_4) else
                $error("instruction: %s: alu_b_src: exp: %s, rcv: %s",
                    instruction.name, "ALU_B_CONST_4", alu_b_src.name);
        end else begin
            assert (alu_b_src == ALU_B_RF) else
                $error("instruction: %s: alu_b_src: exp: %s, rcv: %s",
                    instruction.name, "ALU_B_RF", alu_b_src.name);
        end

        instruction = instruction.next();
    end while (instruction != instruction.last());
endtask

task test_rf_we();
    instr_t instruction;

    instruction = instruction.first();

    do begin
        instr = instruction;
        #1;

        if (instruction inside {LUI, AUIPC, ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI,
            ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND}) begin
            assert (rf_we == 1'b1) else
                $error("instruction: %s: rf_we: exp: %b, rcv: %b",
                    instruction.name, 1'b1, rf_we);
        end else if (instruction inside {LB, LH, LW, LBU, LHU}) begin
            for (int i = 0; i < 2; ++i) begin
                lsu_done = i[0];
                #1;

                assert (rf_we == lsu_done) else
                    $error("instruction: %s: rf_we: exp: %b, rcv: %b",
                        instruction.name, lsu_done, rf_we);
            end
        end else if (instruction inside {JAL, JALR}) begin
            for (int i = 0; i < 2; ++i) begin
                instr_valid = i[0];
                #1;

                assert (rf_we == instr_valid) else
                    $error("instruction: %s: rf_we: exp: %b, rcv: %b",
                        instruction.name, instr_valid, rf_we);
            end
        end else begin
            assert (rf_we == 1'b0) else
                $error("instruction: %s: rf_we: exp: %b, rcv: %b",
                    instruction.name, 1'b0, rf_we);
        end

        instruction = instruction.next();
    end while (instruction != instruction.last());
endtask

task test_rf_rd_src();
    instr_t instruction;
    instruction = instruction.first();

    do begin
        instr = instruction;
        #1;

        if (instruction inside {LB, LH, LW, LBU, LHU}) begin
            assert (rf_rd_src == RF_RD_LSU) else
                $error("instruction: %s: rf_rd_src: exp: %s, rcv: %s",
                    instruction.name, "RF_RD_LSU", rf_rd_src.name);
        end else if (instruction == LUI) begin
            assert (rf_rd_src == RF_RD_IMM) else
                $error("instruction: %s: rf_rd_src: exp: %s, rcv: %s",
                    instruction.name, "RF_RD_IMM", rf_rd_src.name);
        end else begin
            assert (rf_rd_src == RF_RD_ALU) else
                $error("instruction: %s: rf_rd_src: exp: %s, rcv: %s",
                    instruction.name, "RF_RD_ALU", rf_rd_src.name);
        end

        instruction = instruction.next();
    end while (instruction != instruction.last());
endtask

task test_ifu_branch();
    instr_t instruction;
    instruction = instruction.first();

    do begin
        instr = instruction;
        #1;

        if (instruction == BEQ) begin
            for (int i = 0; i < 2; ++i) begin
                alu_eq = i[0];
                #1;

                assert (ifu_branch == i[0]) else
                    $error("instruction: %s: ifu_branch: exp: %b, rcv: %b",
                        instruction.name, i[0], ifu_branch);
            end
        end else if (instruction == BNE) begin
            for (int i = 0; i < 2; ++i) begin
                alu_eq = i[0];
                #1;

                assert (ifu_branch == ~i[0]) else
                    $error("instruction: %s: ifu_branch: exp: %b, rcv: %b",
                        instruction.name, ~i[0], ifu_branch);
            end
        end else if (instruction inside {BGE, BGEU}) begin
            for (int i = 0; i < 2; ++i) begin
                alu_lt = i[0];
                #1;

                assert (ifu_branch == ~i[0]) else
                    $error("instruction: %s: ifu_branch: exp: %b, rcv: %b",
                        instruction.name, ~i[0], ifu_branch);
            end
        end else if (instruction inside {BLT, BLTU}) begin
            for (int i = 0; i < 2; ++i) begin
                alu_lt = i[0];
                #1;

                assert (ifu_branch == i[0]) else
                    $error("instruction: %s: ifu_branch: exp: %b, rcv: %b",
                        instruction.name, i[0], ifu_branch);
            end
        end else begin
            assert (ifu_branch == 1'b0) else
                $error("instruction: %s: ifu_branch: exp: %b, rcv: %b",
                    instruction.name, 1'b0, ifu_branch);
        end

        instruction = instruction.next();
    end while (instruction != instruction.last());
endtask

task test_ifu_relative_jump();
    instr_t instruction;
    instruction = instruction.first();

    do begin
        instr = instruction;
        #1;

        if (instruction == JAL) begin
            assert (ifu_relative_jump == 1'b1) else
                $error("instruction: %s: ifu_relative_jump: exp: %b, rcv: %b",
                    instruction.name, 1'b1, ifu_relative_jump);
        end else begin
            assert (ifu_relative_jump == 1'b0) else
                $error("instruction: %s: ifu_relative_jump: exp: %b, rcv: %b",
                    instruction.name, 1'b0, ifu_relative_jump);
        end

        instruction = instruction.next();
    end while (instruction != instruction.last());
endtask

task test_ifu_absolute_jump();
    instr_t instruction;
    instruction = instruction.first();

    do begin
        instr = instruction;
        #1;

        if (instruction == JALR) begin
            assert (ifu_absolute_jump == 1'b1) else
                $error("instruction: %s: ifu_absolute_jump: exp: %b, rcv: %b",
                    instruction.name, 1'b1, ifu_absolute_jump);
        end else begin
            assert (ifu_absolute_jump == 1'b0) else
                $error("instruction: %s: ifu_absolute_jump: exp: %b, rcv: %b",
                    instruction.name, 1'b0, ifu_absolute_jump);
        end

        instruction = instruction.next();
    end while (instruction != instruction.last());
endtask

task test_ifu_stall();
    instr_t instruction;
    static instr_t lsu_instructions[$] = {LB, LBU, LH, LHU, LW, SB, SH, SW};

    lsu_done = 1'b0;
    instr_valid = 1'b0;
    instruction = instruction.first();

    u_rst_n_gen.reset();

    do begin
        instr = instruction;
        #1;

        assert (ifu_stall == 1'b0) else
            $error("ifu_stall: exp: %b, rcv: %b", 1'b0, ifu_stall);

        instruction = instruction.next();
    end while (instruction != instruction.last());

    foreach (lsu_instructions[i]) begin
        instr = lsu_instructions[i];
        instr_valid = 1'b1;
        lsu_done = 1'b0;

        u_rst_n_gen.reset();
        #1;

        assert (ifu_stall == 1'b1) else
            $error("ifu_stall: exp: %b, rcv: %b", 1'b1, ifu_stall);

        @(negedge clk) ;
        instr_valid = 1'b0;

        assert (ifu_stall == 1'b1) else
            $error("ifu_stall: exp: %b, rcv: %b", 1'b1, ifu_stall);

        @(negedge clk) ;

        assert (ifu_stall == 1'b1) else
            $error("ifu_stall: exp: %b, rcv: %b", 1'b1, ifu_stall);

        lsu_done = 1'b1;
        #1;

        assert (ifu_stall == 1'b0) else
            $error("ifu_stall: exp: %b, rcv: %b", 1'b0, ifu_stall);
    end
endtask

task test_lsu_op();
    instr_t instruction;
    static instr_t lsu_instructions[$] = {LB, LBU, LH, LHU, LW, SB, SH, SW};
    lsu_op_t exp_lsu_op;

    lsu_done = 1'b0;
    instr_valid = 1'b0;
    instruction = instruction.first();

    u_rst_n_gen.reset();

    do begin
        instr = instruction;
        #1;

        assert (lsu_op == LSU_NONE_OP) else
            $error("instruction: %s: lsu_op: exp: %s, rcv: %s",
                instruction.name, "LSU_NONE_OP", lsu_op.name);

        instruction = instruction.next();
    end while (instruction != instruction.last());

    foreach (lsu_instructions[i]) begin
        instr = lsu_instructions[i];
        instr_valid = 1'b1;
        lsu_done = 1'b0;

        case (instr)
        LB:         exp_lsu_op = LSU_LOAD_BYTE;
        LBU:        exp_lsu_op = LSU_LOAD_BYTE_UNSIGNED;
        LH:         exp_lsu_op = LSU_LOAD_HALF_WORD;
        LHU:        exp_lsu_op = LSU_LOAD_HALF_WORD_UNSIGNED;
        LW:         exp_lsu_op = LSU_LOAD_WORD;
        SB:         exp_lsu_op = LSU_STORE_BYTE;
        SH:         exp_lsu_op = LSU_STORE_HALF_WORD;
        SW:         exp_lsu_op = LSU_STORE_WORD;
        default:    exp_lsu_op = LSU_NONE_OP;
        endcase

        u_rst_n_gen.reset();
        #1;

        assert (dut.lsu_state == 1'b0 && lsu_op == exp_lsu_op) else
            $error("dut.lsu_state: exp: %b, rcv: %b; lsu_op: exp: %s, rcv: %s",
                1'b0, dut.lsu_state, exp_lsu_op.name, lsu_op.name);

        @(negedge clk) ;
        instr_valid = 1'b0;

        assert (dut.lsu_state == 1'b1 && lsu_op == exp_lsu_op) else
            $error("dut.lsu_state: exp: %b, rcv: %b; lsu_op: exp: %s, rcv: %s",
                1'b1, dut.lsu_state, exp_lsu_op.name, lsu_op.name);

        @(negedge clk) ;

        assert (dut.lsu_state == 1'b1 && lsu_op == exp_lsu_op) else
            $error("dut.lsu_state: exp: %b, rcv: %b; lsu_op: exp: %s, rcv: %s",
                1'b1, dut.lsu_state, exp_lsu_op.name, lsu_op.name);

        lsu_done = 1'b1;

        @(negedge clk) ;
        exp_lsu_op = LSU_NONE_OP;

        assert (dut.lsu_state == 1'b0 && lsu_op == exp_lsu_op) else
        $error("dut.lsu_state: exp: %b, rcv: %b; lsu_op: exp: %s, rcv: %s",
            1'b0, dut.lsu_state, exp_lsu_op.name, lsu_op.name);
    end
endtask


/* Test */

initial begin
    instr_valid = 1'b0;
    instr = INVALID;
    alu_eq = 1'b0;
    alu_lt = 1'b0;
    lsu_done = 1'b0;

    u_rst_n_gen.reset();

    for (int i = 0; i < 100; ++i) begin
        test_alu_op();
        test_alu_a_src();
        test_alu_b_src();
        test_rf_we();
        test_rf_rd_src();
        test_ifu_branch();
        test_ifu_relative_jump();
        test_ifu_absolute_jump();
        test_ifu_stall();
        test_lsu_op();
    end

    $finish;
end

endmodule
