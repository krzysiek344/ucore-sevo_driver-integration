module tb_soc_servo;


/* Local variables and signals */

logic       clk, rst_n;
logic [3:0] stepper_phases;
logic       servo_sensor_raw;


/* Constants */

const int GO_TO_TIMEOUT_CYCLES = 5000;

const logic [31:0] EXP_SERVO_CR_GO_TO_DONE = 32'h0000_0001;
const logic [31:0] EXP_SERVO_SR_GO_TO_DONE = 32'h0000_000a;


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
    int timeout;
    logic phases_changed;

    timeout = 0;
    phases_changed = 1'b0;

    while (timeout < GO_TO_TIMEOUT_CYCLES && dut.u_servo.sr[1] == 1'b0) begin
        @(negedge clk);

        if (stepper_phases != 4'b0)
            phases_changed = 1'b1;

        timeout++;
    end

    assert (timeout < GO_TO_TIMEOUT_CYCLES) else
        $error("go_to timeout");

    assert (phases_changed) else
        $error("stepper_phases did not change");

    assert (dut.u_servo.sr == EXP_SERVO_SR_GO_TO_DONE) else
        $error("sr: exp: 0x%x, rcv: 0x%x", EXP_SERVO_SR_GO_TO_DONE, dut.u_servo.sr);

    assert (dut.u_servo.cr == EXP_SERVO_CR_GO_TO_DONE) else
        $error("cr: exp: 0x%x, rcv: 0x%x", EXP_SERVO_CR_GO_TO_DONE, dut.u_servo.cr);
endtask


/* Test */

initial begin
    initialize_code_rom();

    servo_sensor_raw = 1'b1;

    u_rst_n_gen.reset();

    test_servo_go_to();

    $finish;
end

endmodule
