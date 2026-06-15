module tb_servo_step_counter;


/* Local variables and signals */

logic       clk, rst_n;
logic [7:0] current_pos;
logic       step_tick;
logic       dir;
logic       set_zero;


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

step_counter #(
    .POS_RANGE(8)
) dut (
    .clk,
    .rst_n,

    .current_pos,
    .step_tick,
    .dir,
    .set_zero
);


/* Tasks and functions definitions */

task check_pos(input logic [7:0] exp_pos);
    assert (current_pos == exp_pos) else
        $error("current_pos: exp: 0x%x, rcv: 0x%x", exp_pos, current_pos);
endtask

task clear_inputs();
    step_tick = 1'b0;
    dir = 1'b0;
    set_zero = 1'b0;
endtask

task apply_step(input logic dir_val);
    @(negedge clk);
    dir = dir_val;
    step_tick = 1'b1;

    @(negedge clk);
    step_tick = 1'b0;
    #1;
endtask

task apply_set_zero_with_step();
    @(negedge clk);
    dir = 1'b1;
    step_tick = 1'b1;
    set_zero = 1'b1;

    @(negedge clk);
    step_tick = 1'b0;
    set_zero = 1'b0;
    #1;
endtask

task test_reset();
    step_tick = 1'b1;
    dir = 1'b1;
    set_zero = 1'b1;

    u_rst_n_gen.reset();

    #1;
    check_pos(8'b0);
    clear_inputs();
endtask

task test_hold_without_step_tick();
    clear_inputs();
    dir = 1'b1;

    u_rst_n_gen.reset();

    repeat (5) begin
        @(negedge clk);
        #1;
        check_pos(8'b0);
    end

    dir = 1'b0;

    repeat (5) begin
        @(negedge clk);
        #1;
        check_pos(8'b0);
    end
endtask

task test_increment();
    clear_inputs();
    u_rst_n_gen.reset();

    for (int i = 1; i <= 5; ++i) begin
        apply_step(1'b1);
        check_pos(i);
    end
endtask

task test_decrement();
    clear_inputs();
    u_rst_n_gen.reset();

    for (int i = 1; i <= 5; ++i)
        apply_step(1'b1);

    check_pos(8'd5);

    for (int i = 4; i >= 0; --i) begin
        apply_step(1'b0);
        check_pos(i);
    end
endtask

task test_set_zero_priority();
    clear_inputs();
    u_rst_n_gen.reset();

    for (int i = 1; i <= 3; ++i)
        apply_step(1'b1);

    check_pos(8'd3);

    apply_set_zero_with_step();
    check_pos(8'b0);
endtask


/* Test */

initial begin
    clear_inputs();

    u_rst_n_gen.reset();

    test_reset();
    test_hold_without_step_tick();
    test_increment();
    test_decrement();
    test_set_zero_priority();

    $finish;
end

endmodule
