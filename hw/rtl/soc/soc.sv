/* Copyright (C) 2025  AGH University of Krakow */

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


/* Local variables and signals */

ibus core_ibus ();

dbus core_dbus ();
dbus code_rom_dbus ();
dbus data_ram_dbus ();
dbus gpio_dbus ();
dbus timer_dbus ();
dbus uart_dbus ();
dbus servo_dbus ();


/* Submodules placement */

core u_core (
    .clk,
    .rst_n,

    .ibus(core_ibus),
    .dbus(core_dbus)
);

dbus_arbiter u_dbus_arbiter (
    .clk,
    .rst_n,

    .core_dbus,

    .code_rom_dbus,
    .data_ram_dbus,
    .gpio_dbus,
    .timer_dbus,
    .uart_dbus,
    .servo_dbus
);

code_rom u_code_rom (
    .clk,
    .rst_n,

    .ibus(core_ibus),
    .dbus(code_rom_dbus)
);

data_ram u_data_ram (
    .clk,
    .rst_n,

    .dbus(data_ram_dbus)
);

gpio u_gpio (
    .clk,
    .rst_n,

    .dbus(gpio_dbus),

    .dout(gpio_dout),
    .din(gpio_din)
);

timer u_timer (
    .clk,
    .rst_n,

    .dbus(timer_dbus)
);

uart u_uart (
    .clk,
    .rst_n,

    .dbus(uart_dbus),

    .sout(uart_sout),
    .sin(uart_sin)
);

servo u_servo (
    .clk,
    .rst_n,

    .dbus(servo_dbus),

    .stepper_phases,
    .sensor_raw(servo_sensor_raw)
);

endmodule
