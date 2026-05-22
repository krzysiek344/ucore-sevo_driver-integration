if {$env(console_mode) == "false"} {
    database -open waves -into waves.shm -default
    probe -create -shm \
        tb_soc_data_ram.clk \
        tb_soc_data_ram.rst_n \
        tb_soc_data_ram.dut.u_core.pc \
        tb_soc_data_ram.dut.u_core.instr \
        tb_soc_data_ram.dut.core_ibus.addr \
        tb_soc_data_ram.dut.core_ibus.rreq \
        tb_soc_data_ram.dut.core_ibus.rvalid \
        tb_soc_data_ram.dut.core_ibus.rdata \
        tb_soc_data_ram.dut.core_dbus.addr \
        tb_soc_data_ram.dut.core_dbus.be \
        tb_soc_data_ram.dut.core_dbus.rreq \
        tb_soc_data_ram.dut.core_dbus.wreq \
        tb_soc_data_ram.dut.core_dbus.wdata \
        tb_soc_data_ram.dut.core_dbus.stall \
        tb_soc_data_ram.dut.core_dbus.rvalid \
        tb_soc_data_ram.dut.core_dbus.rdata

    simvision -submit window new WaveWindow -name "waveform"
    simvision -submit waveform using {waveform}
    simvision -submit waveform add -signals \
        tb_soc_data_ram.clk \
        tb_soc_data_ram.rst_n

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_soc_data_ram.dut.u_core.pc \
        tb_soc_data_ram.dut.u_core.instr

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_soc_data_ram.dut.core_ibus.addr \
        tb_soc_data_ram.dut.core_ibus.rreq \
        tb_soc_data_ram.dut.core_ibus.rvalid \
        tb_soc_data_ram.dut.core_ibus.rdata

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_soc_data_ram.dut.core_dbus.addr \
        tb_soc_data_ram.dut.core_dbus.be \
        tb_soc_data_ram.dut.core_dbus.rreq \
        tb_soc_data_ram.dut.core_dbus.wreq \
        tb_soc_data_ram.dut.core_dbus.wdata \
        tb_soc_data_ram.dut.core_dbus.stall \
        tb_soc_data_ram.dut.core_dbus.rvalid \
        tb_soc_data_ram.dut.core_dbus.rdata
}

run
