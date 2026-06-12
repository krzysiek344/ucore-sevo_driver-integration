module tb_servo_master_fsm;


/* Constants */

localparam logic [2:0] IDLE          = 3'd0,
                       CALLIB_FIND   = 3'd1,
                       CALLIB_DONE   = 3'd2,
                       MOVE_EVALUATE = 3'd3,
                       MOVE_RUN      = 3'd4,
                       MOVE_DONE     = 3'd5;


/* Local variables and signals */

logic       clk, rst_n;
logic       set_zero;
logic       dir;
logic       callib_done;
logic       prescaler_enable;
logic       enable;
logic       callib;
logic       go_to;
logic       sensor_clean;
logic [7:0] target_position;
logic [7:0] current_position;


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

master_fsm #(
    .POS_RANGE(8)
) dut (
    .clk,
    .rst_n,

    .set_zero,
    .dir,
    .callib_done,
    .prescaler_enable,

    .enable,
    .callib,
    .go_to,

    .sensor_clean,
    .target_position,
    .current_position
);


/* Tasks and functions definitions */

task clear_inputs();
    enable = 1'b0;
    callib = 1'b0;
    go_to = 1'b0;
    sensor_clean = 1'b0;
    target_position = 8'b0;
    current_position = 8'b0;
endtask

task wait_cycle();
    @(negedge clk);
    #1;
endtask

task check_state(input logic [2:0] exp_state);
    assert (dut.state == exp_state) else
        $error("state: exp: %0d, rcv: %0d", exp_state, dut.state);
endtask

task check_idle_outputs();
    assert ({set_zero, callib_done, prescaler_enable} == 3'b000) else
        $error("idle outputs: set_zero: %b, callib_done: %b, prescaler_enable: %b",
            set_zero, callib_done, prescaler_enable);
endtask

task check_outputs(
    input logic exp_set_zero,
    input logic exp_callib_done,
    input logic exp_prescaler_enable
);
    assert ({set_zero, callib_done, prescaler_enable} ==
        {exp_set_zero, exp_callib_done, exp_prescaler_enable}) else
        $error("outputs: exp: %b%b%b, rcv: %b%b%b",
            exp_set_zero, exp_callib_done, exp_prescaler_enable,
            set_zero, callib_done, prescaler_enable);
endtask

task check_dir(input logic exp_dir);
    assert (dir == exp_dir) else
        $error("dir: exp: %b, rcv: %b", exp_dir, dir);
endtask

task test_reset();
    enable = 1'b1;
    callib = 1'b1;
    go_to = 1'b1;
    sensor_clean = 1'b1;
    target_position = 8'd5;
    current_position = 8'd2;

    u_rst_n_gen.reset();

    #1;
    check_state(IDLE);
    check_idle_outputs();
    check_dir(1'b0);
endtask

task test_enable_low_keeps_idle();
    clear_inputs();

    u_rst_n_gen.reset();

    callib = 1'b1;
    go_to = 1'b1;
    sensor_clean = 1'b1;
    target_position = 8'd8;
    current_position = 8'd1;

    wait_cycle();

    check_state(IDLE);
    check_idle_outputs();
endtask

task test_callib_sequence();
    clear_inputs();

    u_rst_n_gen.reset();

    enable = 1'b1;
    callib = 1'b1;
    sensor_clean = 1'b0;

    wait_cycle();
    check_state(CALLIB_FIND);
    check_outputs(1'b0, 1'b0, 1'b1);

    wait_cycle();
    check_state(CALLIB_FIND);
    check_outputs(1'b0, 1'b0, 1'b1);

    sensor_clean = 1'b1;

    wait_cycle();
    check_state(CALLIB_DONE);
    check_outputs(1'b1, 1'b1, 1'b0);

    wait_cycle();
    check_state(CALLIB_DONE);
    check_outputs(1'b1, 1'b1, 1'b0);

    callib = 1'b0;

    wait_cycle();
    check_state(IDLE);
    check_idle_outputs();
endtask

task test_go_to_forward();
    clear_inputs();

    u_rst_n_gen.reset();

    enable = 1'b1;
    go_to = 1'b1;
    target_position = 8'd5;
    current_position = 8'd2;

    wait_cycle();
    check_state(MOVE_EVALUATE);
    check_outputs(1'b0, 1'b0, 1'b0);

    wait_cycle();
    check_state(MOVE_RUN);
    check_outputs(1'b0, 1'b0, 1'b1);
    check_dir(1'b1);

    go_to = 1'b0;
    current_position = target_position;

    wait_cycle();
    check_state(MOVE_DONE);
    check_idle_outputs();

    wait_cycle();
    check_state(IDLE);
    check_idle_outputs();
endtask

task test_go_to_backward();
    clear_inputs();

    u_rst_n_gen.reset();

    enable = 1'b1;
    go_to = 1'b1;
    target_position = 8'd2;
    current_position = 8'd5;

    wait_cycle();
    check_state(MOVE_EVALUATE);
    check_outputs(1'b0, 1'b0, 1'b0);

    wait_cycle();
    check_state(MOVE_RUN);
    check_outputs(1'b0, 1'b0, 1'b1);
    check_dir(1'b0);

    go_to = 1'b0;
    current_position = target_position;

    wait_cycle();
    check_state(MOVE_DONE);
    check_idle_outputs();

    wait_cycle();
    check_state(IDLE);
    check_idle_outputs();
endtask

task test_go_to_already_at_target();
    clear_inputs();

    u_rst_n_gen.reset();

    enable = 1'b1;
    go_to = 1'b1;
    target_position = 8'd3;
    current_position = 8'd3;

    wait_cycle();
    check_state(MOVE_EVALUATE);
    check_outputs(1'b0, 1'b0, 1'b0);

    go_to = 1'b0;

    wait_cycle();
    check_state(IDLE);
    check_idle_outputs();
endtask

task test_callib_has_priority_during_move();
    clear_inputs();

    u_rst_n_gen.reset();

    enable = 1'b1;
    go_to = 1'b1;
    target_position = 8'd7;
    current_position = 8'd1;

    wait_cycle();
    check_state(MOVE_EVALUATE);

    wait_cycle();
    check_state(MOVE_RUN);
    check_outputs(1'b0, 1'b0, 1'b1);
    check_dir(1'b1);

    callib = 1'b1;

    wait_cycle();
    check_state(CALLIB_FIND);
    check_outputs(1'b0, 1'b0, 1'b1);

    wait_cycle();
    check_dir(1'b0);

    sensor_clean = 1'b1;
    go_to = 1'b0;

    wait_cycle();
    check_state(CALLIB_DONE);
    check_outputs(1'b1, 1'b1, 1'b0);
endtask

task test_enable_low_returns_to_idle();
    clear_inputs();

    u_rst_n_gen.reset();

    enable = 1'b1;
    go_to = 1'b1;
    target_position = 8'd6;
    current_position = 8'd1;

    wait_cycle();
    check_state(MOVE_EVALUATE);

    wait_cycle();
    check_state(MOVE_RUN);
    check_outputs(1'b0, 1'b0, 1'b1);

    enable = 1'b0;

    wait_cycle();
    check_state(IDLE);
    check_idle_outputs();
endtask


/* Test */

initial begin
    clear_inputs();

    u_rst_n_gen.reset();

    test_reset();
    test_enable_low_keeps_idle();
    test_callib_sequence();
    test_go_to_forward();
    test_go_to_backward();
    test_go_to_already_at_target();
    test_callib_has_priority_during_move();
    test_enable_low_returns_to_idle();

    $finish;
end

endmodule
