module tb_soc_servo;


/* Local variables and signals */

logic       clk, rst_n;
logic [3:0] stepper_phases;
logic       servo_sensor_raw;


/* Submodules placement */

clk_gen #(
    .FREQUENCY_MHZ(50)
) u_clk_gen (
    .clk
);

rst_n_gen u_rst_n_gen (
    .rst_n,
    .clk
);

soc dut (
    .clk,
    .rst_n,

    .uart_sout(),
    .uart_sin(1'b1),

    .gpio_dout(),
    .gpio_din(32'b0),

    .stepper_phases,
    .servo_sensor_raw
);


/* Tasks and functions definitions */

function void initialize_code_rom();
    $readmemh("sw/build/app.mem", dut.u_code_rom.mem);
endfunction

task test_servo_go_to();
    for (int i = 0; i < 500; ++i)
        @(negedge clk);

    assert (dut.u_servo.current_pos == 32'd3) else
        $error("current_pos: exp: 0x%x, rcv: 0x%x", 32'd3, dut.u_servo.current_pos);

    assert (dut.u_servo.sr == 32'h0000_0002) else
        $error("sr: exp: 0x%x, rcv: 0x%x", 32'h0000_0002, dut.u_servo.sr);
endtask


/* Test */

initial begin
    initialize_code_rom();

    servo_sensor_raw = 1'b0;

    u_rst_n_gen.reset();

    test_servo_go_to();

    $finish;
end

endmodule