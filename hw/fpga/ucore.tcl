create_project ucore build -part xc7a35tcpg236-1 -force

set_property verilog_define {FPGA} [get_filesets sources_1]

read_verilog -sv {
    ../rtl/core/core_pkg.sv
    ../rtl/core/ibus.sv
    ../rtl/core/dbus.sv
    ../rtl/core/alu.sv
    ../rtl/core/cu.sv
    ../rtl/core/idu.sv
    ../rtl/core/ifu.sv
    ../rtl/core/lsu.sv
    ../rtl/core/rf.sv
    ../rtl/core/core.sv

    ../rtl/soc/memory_map.sv
    ../rtl/soc/dbus_arbiter.sv
    ../rtl/soc/code_rom.sv
    ../rtl/soc/data_ram.sv
    ../rtl/soc/gpio.sv
    ../rtl/soc/timer_counter.sv
    ../rtl/soc/timer.sv
    ../rtl/soc/uart_clock_generator.sv
    ../rtl/soc/uart_receiver.sv
    ../rtl/soc/uart_transmitter.sv
    ../rtl/soc/uart.sv
    ../rtl/soc/soc.sv

    rtl/pll.sv
    rtl/reset_synchronizer.sv
    rtl/ucore_basys3.sv
}

set_property top ucore_basys3 [current_fileset]
update_compile_order -fileset sources_1

read_xdc constraints/basys3.xdc

add_files -norecurse $env(ROOTDIR)/sw/app/build/app.mem
set_property file_type {Memory Initialization Files} [get_files $env(ROOTDIR)/sw/app/build/app.mem]

launch_runs synth_1 -jobs 8
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
exit
