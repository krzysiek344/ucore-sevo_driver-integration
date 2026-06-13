module pll (
    input  logic refclk,
    input  logic io_rst_n,

    output logic clk,
    output logic locked
);

assign clk = refclk;
assign locked = io_rst_n;

endmodule

module soc (
    input logic         clk,
    input logic         rst_n,

    output logic        uart_sout,
    input logic         uart_sin,

    output logic [31:0] gpio_dout,
    input logic [31:0]  gpio_din,

    output logic [3:0]  stepper_phases,
    input logic         servo_sensor_raw
);

always_comb begin
    gpio_dout = 32'b0;
    uart_sout = 1'b0;
    stepper_phases = 4'b0;

    if (rst_n) begin
        gpio_dout = gpio_din;
        uart_sout = uart_sin;
        stepper_phases = servo_sensor_raw ? gpio_din[3:0] : ~gpio_din[3:0];
    end
end

endmodule

module tb_fpga_ucore_basys3;


/* Local variables and signals */

logic       refclk;
logic       btnC;
logic       RsTx;
logic       RsRx;
logic [8:0] led;
logic [3:0] sw;
logic [3:0] stepper_phases;
logic       servo_sensor_raw;


/* Submodules placement */

clk_gen #(
    .FREQUENCY_MHZ(100)
) u_clk_gen (
    .clk(refclk)
);

ucore_basys3 dut (
    .refclk,

    .btnC,

    .RsTx,
    .RsRx,

    .led,
    .sw,

    .stepper_phases,
    .servo_sensor_raw
);


/* Tasks and functions definitions */

task wait_cycles(input int cycles);
    repeat (cycles) begin
        @(negedge refclk);
        #1;
    end
endtask

task check_stepper(input logic [3:0] exp_stepper_phases);
    assert (stepper_phases == exp_stepper_phases) else
        $error("stepper_phases: exp: %b, rcv: %b", exp_stepper_phases, stepper_phases);
endtask

task check_leds();
    assert (led[3:0] == stepper_phases) else
        $error("led[3:0]: exp: %b, rcv: %b", stepper_phases, led[3:0]);

    assert (led[4] == sw[2]) else
        $error("led[4]: exp: %b, rcv: %b", sw[2], led[4]);

    assert (led[8:5] == sw) else
        $error("led[8:5]: exp: %b, rcv: %b", sw, led[8:5]);
endtask

task check_uart(input logic exp_uart_sout);
    assert (RsTx == exp_uart_sout) else
        $error("RsTx: exp: %b, rcv: %b", exp_uart_sout, RsTx);
endtask

task test_reset_button();
    sw = 4'b1011;
    servo_sensor_raw = 1'b1;
    RsRx = 1'b1;

    btnC = 1'b0;
    wait_cycles(5);

    check_stepper(4'b1011);
    check_uart(1'b1);

    btnC = 1'b1;
    wait_cycles(2);

    check_stepper(4'b0000);
    check_uart(1'b0);
    check_leds();

    btnC = 1'b0;
    wait_cycles(5);
endtask

task test_switches_reach_soc();
    btnC = 1'b0;
    servo_sensor_raw = 1'b1;
    RsRx = 1'b1;

    sw = 4'b1101;
    wait_cycles(1);

    check_stepper(4'b1101);
    check_leds();

    sw = 4'b0010;
    wait_cycles(1);

    check_stepper(4'b0010);
    check_leds();
endtask

task test_sensor_reaches_soc();
    btnC = 1'b0;
    sw = 4'b0011;
    RsRx = 1'b1;

    servo_sensor_raw = 1'b1;
    wait_cycles(1);

    check_stepper(4'b0011);
    check_leds();

    servo_sensor_raw = 1'b0;
    wait_cycles(1);

    check_stepper(4'b1100);
    check_leds();
endtask

task test_uart_connection();
    btnC = 1'b0;
    sw = 4'b0000;
    servo_sensor_raw = 1'b1;

    RsRx = 1'b0;
    wait_cycles(1);
    check_uart(1'b0);

    RsRx = 1'b1;
    wait_cycles(1);
    check_uart(1'b1);
endtask


/* Test */

initial begin
    btnC = 1'b1;
    RsRx = 1'b1;
    sw = 4'b0;
    servo_sensor_raw = 1'b1;

    wait_cycles(5);

    test_reset_button();
    test_switches_reach_soc();
    test_sensor_reaches_soc();
    test_uart_connection();

    $finish;
end

endmodule
