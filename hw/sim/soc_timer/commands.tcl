if {$env(console_mode) == "false"} {
    database -open waves -into waves.shm -default
    probe -create -shm \
        tb_soc_timer.clk \
        tb_soc_timer.rst_n \
        tb_soc_timer.dut.u_core.pc \
        tb_soc_timer.dut.u_core.instr \
        tb_soc_timer.gpio_dout \
        tb_soc_timer.dut.u_timer.cr \
        tb_soc_timer.dut.u_timer.sr

    simvision -submit window new WaveWindow -name "waveform"
    simvision -submit waveform using {waveform}
    simvision -submit waveform add -signals \
        tb_soc_timer.clk \
        tb_soc_timer.rst_n

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_soc_timer.dut.u_core.pc \
        tb_soc_timer.dut.u_core.instr

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_soc_timer.gpio_dout

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_soc_timer.dut.u_timer.cr \
        tb_soc_timer.dut.u_timer.sr
}

run
