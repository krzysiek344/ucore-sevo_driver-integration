module tb_servo_wrapper;


/* Local variables and signals */

logic       clk, rst_n;
logic [3:0] stepper_phases;
logic       sensor_raw;

dbus servo_dbus ();


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

servo dut (
    .clk,
    .rst_n,

    .dbus(servo_dbus),

    .stepper_phases,
    .sensor_raw
);


/* Test */

initial begin
    servo_dbus.addr = 32'b0;
    servo_dbus.be = 4'b0;
    servo_dbus.rreq = 1'b0;
    servo_dbus.wreq = 1'b0;
    servo_dbus.wdata = 32'b0;

    sensor_raw = 1'b0;

    u_rst_n_gen.reset();

    for (int i = 0; i < 10; ++i)
        @(negedge clk);

    $finish;
end

endmodule