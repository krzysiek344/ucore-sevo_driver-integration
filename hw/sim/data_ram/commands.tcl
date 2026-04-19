if {$env(console_mode) == "false"} {
    database -open waves -into waves.shm -default
    probe -create -shm \
        tb_data_ram.clk \
        tb_data_ram.rst_n \
        tb_data_ram.dut.u_core.pc \
        tb_data_ram.dut.u_core.instr \
        tb_data_ram.dut.core_ibus.addr \
        tb_data_ram.dut.core_ibus.rreq \
        tb_data_ram.dut.core_ibus.rvalid \
        tb_data_ram.dut.core_ibus.rdata \
        tb_data_ram.dut.core_dbus.address \
        tb_data_ram.dut.core_dbus.byteenable \
        tb_data_ram.dut.core_dbus.read \
        tb_data_ram.dut.core_dbus.write \
        tb_data_ram.dut.core_dbus.writedata \
        tb_data_ram.dut.core_dbus.waitrequest \
        tb_data_ram.dut.core_dbus.readdatavalid \
        tb_data_ram.dut.core_dbus.readdata

    simvision -submit window new WaveWindow -name "waveform"
    simvision -submit waveform using {waveform}
    simvision -submit waveform add -signals \
        tb_data_ram.clk \
        tb_data_ram.rst_n

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_data_ram.dut.u_core.pc \
        tb_data_ram.dut.u_core.instr

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_data_ram.dut.core_ibus.addr \
        tb_data_ram.dut.core_ibus.rreq \
        tb_data_ram.dut.core_ibus.rvalid \
        tb_data_ram.dut.core_ibus.rdata

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_data_ram.dut.core_dbus.address \
        tb_data_ram.dut.core_dbus.byteenable \
        tb_data_ram.dut.core_dbus.read \
        tb_data_ram.dut.core_dbus.write \
        tb_data_ram.dut.core_dbus.writedata \
        tb_data_ram.dut.core_dbus.waitrequest \
        tb_data_ram.dut.core_dbus.readdatavalid \
        tb_data_ram.dut.core_dbus.readdata
}

run
