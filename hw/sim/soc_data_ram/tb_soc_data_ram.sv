/* Copyright (C) 2025  AGH University of Krakow */

module tb_soc_data_ram;


/* Local variables and signals */

logic clk, rst_n;


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

    .gpio_dout(),
    .gpio_din(32'b0)
);


/* Tasks and functions definitions */

function void initialize_code_rom();
    $readmemh("sw/build/app.mem", dut.u_code_rom.mem);
endfunction

task test_data_ram();
    for (int i = 0; i < 60000; ++i)
        @(negedge clk) ;

    for (int i = 0; i < 1024; ++i) begin
        assert (dut.u_data_ram.mem[i] == i) else
            $error("dut.u_data_ram.mem[%3d]: exp: 0x%x, rcv: 0x%x", i, i, dut.u_data_ram.mem[i]);
    end
endtask


/* Test */

initial begin
    initialize_code_rom();

    u_rst_n_gen.reset();

    test_data_ram();

    $finish;
end

endmodule
