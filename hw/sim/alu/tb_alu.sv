/* Copyright (C) 2025  AGH University of Krakow */

module tb_alu
    import core_pkg::*;
();


/* Local variables and signals */

alu_op_t     op;
logic [31:0] y, a, b;
logic        eq, lt;


/* Submodules placement */

alu dut (
    .op,

    .eq,
    .lt,

    .y,
    .a,
    .b
);


/* Tasks and functions definitions */

task test_operation(alu_op_t alu_op);
    logic [31:0] exp_y;
    logic        exp_eq, exp_lt;

    op = alu_op;
    a = $random();
    b = $random();

    case (op)
    ALU_OP_ADD:     {exp_y, exp_eq, exp_lt} = {a + b, 1'b0, 1'b0};
    ALU_OP_SLT:     {exp_y, exp_eq, exp_lt} = {{31'b0, $signed(a) < $signed(b)}, 1'b0, $signed(a) < $signed(b)};
    ALU_OP_SLTU:    {exp_y, exp_eq, exp_lt} = {{31'b0, a < b}, 1'b0, a < b};
    ALU_OP_AND:     {exp_y, exp_eq, exp_lt} = {a & b , 1'b0, 1'b0};
    ALU_OP_OR:      {exp_y, exp_eq, exp_lt} = {a | b , 1'b0, 1'b0};
    ALU_OP_XOR:     {exp_y, exp_eq, exp_lt} = {a ^ b , 1'b0, 1'b0};
    ALU_OP_SLL:     {exp_y, exp_eq, exp_lt} = {a << b[4:0] , 1'b0, 1'b0};
    ALU_OP_SRL:     {exp_y, exp_eq, exp_lt} = {a >> b[4:0] , 1'b0, 1'b0};
    ALU_OP_SUB:     {exp_y, exp_eq, exp_lt} = {a - b, (a - b == 0), 1'b0};
    ALU_OP_SRA:     {exp_y, exp_eq, exp_lt} = {a >>> b[4:0], 1'b0, 1'b0};
    default:        {exp_y, exp_eq, exp_lt} = {32'b0, 1'b0, 1'b0};
    endcase

    #1;
    assert (y == exp_y && eq == exp_eq && lt == exp_lt) else
        $error("alu_op: %s, a: %d, b: %d; y: exp: %d, rcv: %d; eq: exp: %b, rcv: %b; lt: exp: %b, rcv: %b",
            alu_op.name(), a, b, exp_y, y, exp_eq, eq, exp_lt, lt);
endtask


/* Test */

initial begin
    alu_op_t alu_op;

    op = ALU_OP_INVALID;
    a = 32'b0;
    b = 32'b0;

    for (int i = 0; i < 100; ++i) begin
        alu_op = alu_op.first();
        do begin
            test_operation(alu_op);
            alu_op = alu_op.next();
        end while (alu_op != alu_op.last());
    end

    $finish;
end

endmodule
