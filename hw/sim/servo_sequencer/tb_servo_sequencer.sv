module tb_servo_sequencer;


/* Local variables and signals */

logic       clk, rst_n;
logic [3:0] stepper_phases;
logic       step_tick;
logic       dir;
logic       inversion;


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

sequencer #(
    .COILS_NUM(4)
) dut (
    .clk,
    .rst_n,

    .stepper_phases,
    .step_tick,
    .dir,
    .inversion
);


/* Tasks and functions definitions */

task check_phases(input logic [3:0] exp_phases);
    assert (stepper_phases == exp_phases) else
        $error("stepper_phases: exp: %b, rcv: %b", exp_phases, stepper_phases);
endtask

task clear_inputs();
    step_tick = 1'b0;
    dir = 1'b0;
    inversion = 1'b0;
endtask

task apply_step(input logic dir_val);
    @(negedge clk);
    dir = dir_val;
    step_tick = 1'b1;

    @(negedge clk);
    step_tick = 1'b0;
    #1;
endtask

task test_reset();
    step_tick = 1'b1;
    dir = 1'b1;
    inversion = 1'b0;

    u_rst_n_gen.reset();

    #1;
    check_phases(4'b0001);
    clear_inputs();
endtask

task test_hold_without_step_tick();
    clear_inputs();
    u_rst_n_gen.reset();

    check_phases(4'b0001);

    dir = 1'b1;

    repeat (5) begin
        @(negedge clk);
        #1;
        check_phases(4'b0001);
    end

    dir = 1'b0;

    repeat (5) begin
        @(negedge clk);
        #1;
        check_phases(4'b0001);
    end
endtask

task test_forward_sequence();
    clear_inputs();
    u_rst_n_gen.reset();

    check_phases(4'b0001);

    apply_step(1'b1);
    check_phases(4'b0010);

    apply_step(1'b1);
    check_phases(4'b0100);

    apply_step(1'b1);
    check_phases(4'b1000);

    apply_step(1'b1);
    check_phases(4'b0001);

    apply_step(1'b1);
    check_phases(4'b0010);
endtask

task test_backward_sequence();
    clear_inputs();
    u_rst_n_gen.reset();

    check_phases(4'b0001);

    apply_step(1'b0);
    check_phases(4'b1000);

    apply_step(1'b0);
    check_phases(4'b0100);

    apply_step(1'b0);
    check_phases(4'b0010);

    apply_step(1'b0);
    check_phases(4'b0001);

    apply_step(1'b0);
    check_phases(4'b1000);
endtask

task test_inversion();
    clear_inputs();
    u_rst_n_gen.reset();

    check_phases(4'b0001);

    inversion = 1'b1;
    #1;
    check_phases(4'b1110);

    apply_step(1'b1);
    check_phases(4'b1101);

    apply_step(1'b1);
    check_phases(4'b1011);

    inversion = 1'b0;
    #1;
    check_phases(4'b0100);
endtask


/* Test */

initial begin
    clear_inputs();

    u_rst_n_gen.reset();

    test_reset();
    test_hold_without_step_tick();
    test_forward_sequence();
    test_backward_sequence();
    test_inversion();

    $finish;
end

endmodule
