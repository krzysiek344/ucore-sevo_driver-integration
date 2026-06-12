module tb_servo_debouncer;


/* Constants */

localparam int DELAY_CYCLES = 4;


/* Local variables and signals */

logic clk, rst_n;
logic cleared_signal;
logic signal_in;


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

debouncer #(
    .DELAY_CYCLES(DELAY_CYCLES)
) dut (
    .clk,
    .rst_n,

    .cleared_signal,
    .signal_in
);


/* Tasks and functions definitions */

task check_signal(input logic exp_signal);
    assert (cleared_signal == exp_signal) else
        $error("cleared_signal: exp: %b, rcv: %b", exp_signal, cleared_signal);
endtask

task wait_cycles(input int cycles);
    repeat (cycles) begin
        @(negedge clk);
        #1;
    end
endtask

task test_reset();
    signal_in = 1'b1;

    u_rst_n_gen.reset();

    #1;
    check_signal(1'b0);
endtask

task test_short_high_pulse_ignored();
    signal_in = 1'b0;

    u_rst_n_gen.reset();

    @(negedge clk);
    signal_in = 1'b1;

    wait_cycles(2);

    signal_in = 1'b0;

    wait_cycles(DELAY_CYCLES + 4);
    check_signal(1'b0);
endtask

task test_stable_high_passes_after_delay();
    signal_in = 1'b0;

    u_rst_n_gen.reset();

    @(negedge clk);
    signal_in = 1'b1;
    #1;
    check_signal(1'b0);

    wait_cycles(DELAY_CYCLES - 1);
    check_signal(1'b0);

    wait_cycles(3);
    check_signal(1'b1);
endtask

task test_stable_low_passes_after_delay();
    signal_in = 1'b0;

    u_rst_n_gen.reset();

    @(negedge clk);
    signal_in = 1'b1;

    wait_cycles(DELAY_CYCLES + 2);
    check_signal(1'b1);

    signal_in = 1'b0;
    #1;
    check_signal(1'b1);

    wait_cycles(DELAY_CYCLES - 1);
    check_signal(1'b1);

    wait_cycles(3);
    check_signal(1'b0);
endtask

task test_bounce_before_stable_high();
    signal_in = 1'b0;

    u_rst_n_gen.reset();

    @(negedge clk);
    signal_in = 1'b1;

    wait_cycles(1);
    signal_in = 1'b0;

    wait_cycles(1);
    signal_in = 1'b1;

    wait_cycles(1);
    signal_in = 1'b0;

    wait_cycles(DELAY_CYCLES + 2);
    check_signal(1'b0);

    signal_in = 1'b1;

    wait_cycles(DELAY_CYCLES + 2);
    check_signal(1'b1);
endtask


/* Test */

initial begin
    signal_in = 1'b0;

    u_rst_n_gen.reset();

    test_reset();
    test_short_high_pulse_ignored();
    test_stable_high_passes_after_delay();
    test_stable_low_passes_after_delay();
    test_bounce_before_stable_high();

    $finish;
end

endmodule
