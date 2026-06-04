/* Copyright (C) 2025  AGH University of Krakow */

module tb_soc_gpio;


/* Local variables and signals */

logic        clk, rst_n;

logic [31:0] gpio_dout, gpio_din;


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

    .uart_sout(),
    .uart_sin(1'b1),

    .gpio_dout,
    .gpio_din,

    .stepper_phases(),
    .servo_sensor_raw(1'b0)
);


/* Tasks and functions definitions */

function void initialize_code_rom();
    $readmemh("sw/build/app.mem", dut.u_code_rom.mem);
endfunction

task test_gpio();
    gpio_din = 32'ha5a5a5a5;

    for (int i = 0; i < 200; ++i)
        @(negedge clk);

    assert (gpio_dout == 32'h5a5a5a5a) else
        $error("gpio_dout: exp: 0x%x, rcv: 0x%x", 32'h5a5a5a5a, gpio_dout);
endtask


/* Test */

initial begin
    initialize_code_rom();

    gpio_din = 32'h0;

    u_rst_n_gen.reset();

    for (int i = 0; i < 100; ++i)
        @(negedge clk);

    test_gpio();

    $finish;
end

endmodule
