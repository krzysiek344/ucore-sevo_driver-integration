/* Copyright (C) 2025  AGH University of Krakow */

module tb_core_rf;


/* Local variables and signals */

logic        clk, rst_n;
logic [31:0] rdata1, rdata2, wdata;
logic [4:0]  rs1, rs2, rd;
logic        we;


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

rf dut (
    .clk,
    .rst_n,

    .rs1,
    .rs2,
    .rd,

    .rdata1,
    .rdata2,
    .we,
    .wdata
);


/* Tasks and functions definitions */

task test_zero_reg_write_read();
    @(negedge clk) ;
    rd = 0;
    we = 1'b1;
    wdata = $random();

    @ (negedge clk) ;
    we = 1'b0;
    rs1 = 0;
    rs2 = 0;

    #1;
    assert (rdata1 == 32'b0 && rdata2 == 32'b0) else
        $error("rdata1: exp: %x, rcv: %x; rdata2: exp: %x, rcv: %x",
            32'b0, rdata1, 32'b0, rdata2);
endtask

task test_non_zero_regs_write_read();
    for (int i = 1; i < 32; ++i) begin
        @(negedge clk) ;
        rd = i;
        we = 1'b1;
        wdata = $random();

        @ (negedge clk) ;
        we = 1'b0;
        rs1 = i;
        rs2 = i;

        #1;
        assert (rdata1 == wdata && rdata2 == wdata) else
            $error("reg: %2d: rdata1: exp: %x, rcv: %x; rdata2: exp: %x, rcv: %x",
                i, wdata, rdata1, wdata, rdata2);
    end
endtask


/* Test */

initial begin
    rs1 = 5'b0;
    rs2 = 5'b0;
    rd = 5'b0;
    we = 1'b0;
    wdata = 32'b0;

    u_rst_n_gen.reset();

    for (int i = 0; i < 100; ++i) begin
        test_zero_reg_write_read();
        test_non_zero_regs_write_read();
    end

    $finish;
end

endmodule
