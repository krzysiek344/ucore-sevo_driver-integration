/* Copyright (C) 2025  AGH University of Krakow */

module tb_soc_uart;


/* Local variables and signals */

logic clk, rst_n;

logic uart_sin, uart_sout;

event program_size_requested, sync_message_received;


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

uart_bfm #(
    .BAUD_RATE(115200)
) u_uart_bfm (
    .clk,

    .sout(uart_sin),
    .sin(uart_sout)
);


/* Submodules placement */

soc dut (
    .clk,
    .rst_n,

    .uart_sout,
    .uart_sin,

    .gpio_dout(),
    .gpio_din(4'b0)
);


/* Tasks and functions definitions */

function void initialize_code_rom();
    $readmemh("sw/build/app.mem", dut.u_code_rom.mem);
endfunction

task test_byte_transmission(input logic [7:0] wdata);
    logic [7:0] rdata;

    fork
        u_uart_bfm.write_byte(wdata);
        u_uart_bfm.read_byte(rdata);
    join

    assert (rdata == wdata) else
        $error("rdata: rcv: 0x%x, exp: 0x%x", rdata, wdata);
endtask

task test_message_transmission(input string wdata);
    string rdata;

    fork
        u_uart_bfm.write_message(wdata);
        u_uart_bfm.read_message(rdata);
    join

    assert (rdata == wdata) else
        $error("rdata: exp: %s, rcv: %s", wdata, rdata);
endtask


/* Test */

initial begin
    forever begin
        string message;

        u_uart_bfm.read_message(message, {31{1'b1}});
        $display("core: %s", message);

        if (message == "INFO: provide the size (n) of the program to load (n < 16384, n % 4 = 0): ") begin
            ->program_size_requested;
        end else if (message == "sync") begin
            ->sync_message_received;
            break;
        end
    end
end

initial begin
    initialize_code_rom();

    u_rst_n_gen.reset();

    wait (sync_message_received.triggered);

    for (int i = 0; i < 256; ++i)
        test_byte_transmission(i[7:0]);

    test_message_transmission("hello world");

    $finish;
end

endmodule
