/* Copyright (C) 2025  AGH University of Krakow */

module tb_core_ifu;


/* Local variables and signals */

logic        clk, rst_n;

logic [31:0] pc, ibus_rdata, rf_rdata, imm;
logic        stall, branch, relative_jump, absolute_jump, ibus_rvalid;

ibus         ibus ();


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

ifu dut (
    .clk,
    .rst_n,

    .ibus,

    .stall,
    .branch,
    .relative_jump,
    .absolute_jump,

    .pc,
    .ibus_rvalid,
    .ibus_rdata,
    .rf_rdata,
    .imm
);


/* Tasks and functions definitions */

task test_linear_fetching();
    @(negedge clk)
    ibus.rvalid = 1'b1;

    u_rst_n_gen.reset();

    assert (pc == 0) else
        $error("pc: exp: 0x%x, rcv: 0x%x", 0, pc);

    @(negedge clk) ;
    @(negedge clk) ;

    for (int i = 0; i < 1024; ++i) begin
        assert (pc == 4 * i) else
            $error("pc: exp: 0x%x, rcv: 0x%x", 4 * i, pc);

        @(negedge clk) ;
    end

    ibus.rvalid = 1'b0;
endtask

task test_stall();
    @(negedge clk)
    ibus.rvalid = 1'b1;

    u_rst_n_gen.reset();

    while (pc != 32'h0000_0004)
        @(negedge clk) ;

    stall = 1'b1;

    for (int i = 0; i < 10; ++i)
        @(negedge clk) ;

    stall = 1'b0;

    for (int i = 0; i < 2; ++i) begin
        assert (pc == 4 * i + 4) else
            $error("pc: exp: 0x%x, rcv: 0x%x", 4 * i + 4, pc);

        @(negedge clk) ;
    end

    ibus.rvalid = 1'b0;
endtask

task test_branch();
    logic [31:0] exp_pc;

    @(negedge clk)
    ibus.rvalid = 1'b1;

    @(negedge clk) ;
    branch = 1'b1;
    imm = $random();
    exp_pc = pc + imm;

    @(negedge clk) ;
    branch = 1'b0;

    @(negedge clk);

    assert (pc == exp_pc) else
        $error("pc: exp: 0x%x, rcv: 0x%x", exp_pc, pc);

    ibus.rvalid = 1'b0;
endtask

task test_relative_jump();
    logic [31:0] exp_pc;

    @(negedge clk)
    ibus.rvalid = 1'b1;

    @(negedge clk) ;
    relative_jump = 1'b1;
    imm = $random();
    exp_pc = pc + imm;

    @(negedge clk) ;
    relative_jump = 1'b0;

    @(negedge clk);

    assert (pc == exp_pc) else
        $error("pc: exp: 0x%x, rcv: 0x%x", exp_pc, pc);

    ibus.rvalid = 1'b0;
endtask

task test_absolute_jump();
    logic [31:0] exp_pc;

    @(negedge clk)
    ibus.rvalid = 1'b1;

    @(negedge clk) ;
    absolute_jump = 1'b1;
    rf_rdata = $random();
    imm = $random();
    exp_pc = (rf_rdata + imm) & 32'hffff_fffe;

    @(negedge clk) ;
    absolute_jump = 1'b0;

    @(negedge clk);

    assert (pc == exp_pc) else
        $error("pc: exp: 0x%x, rcv: 0x%x", exp_pc, pc);

    ibus.rvalid = 1'b0;
endtask

task test_ibus_rdata();
    int exp_ibus_rdata;

    u_rst_n_gen.reset();

    ibus.rvalid = 1'b0;
    ibus.rdata = $random();

    for (int i = 0; i < 5; ++i) begin
        assert (ibus_rvalid == 1'b0 && ibus_rdata == 32'b0) else
            $error("ibus_rvalid: exp: %b, rcv: %b; ibus_rdata: exp: 0x%x, rcv: x%x",
                1'b0, ibus_rvalid, 32'b0, ibus_rdata);
        @(negedge clk) ;
    end

    for (int i = 0; i < 5; ++i) begin
        exp_ibus_rdata = $random();
        ibus.rdata = exp_ibus_rdata;
        ibus.rvalid = 1'b1;

        @(negedge clk) ;
        assert (ibus_rvalid == 1'b1 && ibus_rdata == exp_ibus_rdata) else
            $error("ibus_rvalid: exp: %b, rcv: %b; ibus_rdata: exp: 0x%x, rcv: x%x",
                1'b1, ibus_rvalid, exp_ibus_rdata, ibus_rdata);

        ibus.rdata = $random();
        ibus.rvalid = 1'b0;

        @(negedge clk) ;
        assert (ibus_rvalid == 1'b0 && ibus_rdata == exp_ibus_rdata) else
            $error("ibus_rvalid: exp: %b, rcv: %b; ibus_rdata: exp: 0x%x, rcv: x%x",
                1'b0, ibus_rvalid, exp_ibus_rdata, ibus_rdata);
    end

    u_rst_n_gen.reset();

    @(negedge clk) ;
    branch = 1'b1;
    exp_ibus_rdata = $random();
    ibus.rvalid = 1'b0;
    ibus.rdata = exp_ibus_rdata;

    @(negedge clk) ;
    branch = 1'b0;

    for (int i = 0; i < 5; ++i) begin
        @(negedge clk) ;
        assert (ibus_rvalid == 1'b0 && ibus_rdata == 32'b0) else
            $error("ibus_rvalid: exp: %b, rcv: %b; ibus_rdata: exp: 0x%x, rcv: x%x",
                1'b0, ibus_rvalid, 32'b0, ibus_rdata);
    end

    ibus.rvalid = 1'b1;

    assert (ibus_rvalid == 1'b0 && ibus_rdata == 32'b0) else
        $error("ibus_rvalid: exp: %b, rcv: %b; ibus_rdata: exp: 0x%x, rcv: x%x",
            1'b0, ibus_rvalid, 32'b0, ibus_rdata);

    @(negedge clk) ;
    ibus.rvalid = 1'b0;

    assert (ibus_rvalid == 1'b1 && ibus_rdata == exp_ibus_rdata) else
        $error("ibus_rvalid: exp: %b, rcv: %b; ibus_rdata: exp: 0x%x, rcv: x%x",
            1'b1, ibus_rvalid, exp_ibus_rdata, ibus_rdata);
endtask


/* Test */

initial begin
    rf_rdata = 32'b0;
    imm = 32'b0;
    stall = 1'b0;
    branch = 1'b0;
    relative_jump = 1'b0;
    absolute_jump = 1'b0;

    ibus.rdata = 32'b0;
    ibus.rvalid = 1'b0;

    u_rst_n_gen.reset();

    for (int i = 0; i < 100; ++i) begin
        test_linear_fetching();
        test_stall();
        test_branch();
        test_relative_jump();
        test_absolute_jump();
        test_ibus_rdata();
    end

    $finish;
end

endmodule
