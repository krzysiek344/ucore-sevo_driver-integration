/* Copyright (C) 2025  AGH University of Krakow */

module tb_timer;


/* Local variables and signals */

logic        clk, rst_n;

logic [31:0] gpio_dout;


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

soc dut (
    .clk,
    .rst_n,

    .gpio_dout,
    .gpio_din(32'b0)
);


/* Tasks and functions definitions */

function void initialize_code_rom();
    $readmemh("sw/build/app.mem", dut.u_code_rom.mem);
endfunction

task test_timer();
    for (int i = 0; i < 2000; ++i)
        @(negedge clk);

    assert (gpio_dout == dut.u_timer.sr) else
        $error("gpio_dout: exp: 0x%x, rcv: 0x%x", dut.u_timer.sr, gpio_dout);
endtask


/* Test */

initial begin
    initialize_code_rom();

    u_rst_n_gen.reset();

    for (int i = 0; i < 100; ++i)
        @(negedge clk);

    test_timer();

    $finish;
end

endmodule
