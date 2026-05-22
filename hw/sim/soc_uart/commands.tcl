if {$env(console_mode) == "false"} {
    database -open waves -into waves.shm -default
    probe -create -shm \
        tb_soc_uart.clk \
        tb_soc_uart.rst_n \
        tb_soc_uart.dut.u_core.pc \
        tb_soc_uart.dut.u_core.instr \
        tb_soc_uart.dut.core_dbus.addr \
        tb_soc_uart.dut.core_dbus.be \
        tb_soc_uart.dut.core_dbus.rreq \
        tb_soc_uart.dut.core_dbus.wreq \
        tb_soc_uart.dut.core_dbus.wdata \
        tb_soc_uart.dut.core_dbus.stall \
        tb_soc_uart.dut.core_dbus.rvalid \
        tb_soc_uart.dut.core_dbus.rdata \
        tb_soc_uart.dut.uart_dbus.addr \
        tb_soc_uart.dut.uart_dbus.be \
        tb_soc_uart.dut.uart_dbus.rreq \
        tb_soc_uart.dut.uart_dbus.wreq \
        tb_soc_uart.dut.uart_dbus.wdata \
        tb_soc_uart.dut.uart_dbus.stall \
        tb_soc_uart.dut.uart_dbus.rvalid \
        tb_soc_uart.dut.uart_dbus.rdata \
        tb_soc_uart.dut.u_uart.cr \
        tb_soc_uart.dut.u_uart.sr \
        tb_soc_uart.dut.u_uart.ccr \
        tb_soc_uart.dut.u_uart.wdr \
        tb_soc_uart.dut.u_uart.rdr \
        tb_soc_uart.dut.u_uart.sout \
        tb_soc_uart.dut.u_uart.sin

    simvision -submit window new WaveWindow -name "waveform"
    simvision -submit waveform using {waveform}
    simvision -submit waveform add -signals \
        tb_soc_uart.clk \
        tb_soc_uart.rst_n

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_soc_uart.dut.u_core.pc \
        tb_soc_uart.dut.u_core.instr

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_soc_uart.dut.core_dbus.addr \
        tb_soc_uart.dut.core_dbus.be \
        tb_soc_uart.dut.core_dbus.rreq \
        tb_soc_uart.dut.core_dbus.wreq \
        tb_soc_uart.dut.core_dbus.wdata \
        tb_soc_uart.dut.core_dbus.stall \
        tb_soc_uart.dut.core_dbus.rvalid \
        tb_soc_uart.dut.core_dbus.rdata

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_soc_uart.dut.uart_dbus.addr \
        tb_soc_uart.dut.uart_dbus.be \
        tb_soc_uart.dut.uart_dbus.rreq \
        tb_soc_uart.dut.uart_dbus.wreq \
        tb_soc_uart.dut.uart_dbus.wdata \
        tb_soc_uart.dut.uart_dbus.stall \
        tb_soc_uart.dut.uart_dbus.rvalid \
        tb_soc_uart.dut.uart_dbus.rdata

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_soc_uart.dut.u_uart.cr \
        tb_soc_uart.dut.u_uart.sr \
        tb_soc_uart.dut.u_uart.ccr \
        tb_soc_uart.dut.u_uart.wdr \
        tb_soc_uart.dut.u_uart.rdr

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_soc_uart.dut.u_uart.sout \
        tb_soc_uart.dut.u_uart.sin
}

run
