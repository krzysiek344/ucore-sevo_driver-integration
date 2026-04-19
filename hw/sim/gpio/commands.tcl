if {$env(console_mode) == "false"} {
    database -open waves -into waves.shm -default
    probe -create -shm \
        tb_gpio.clk \
        tb_gpio.rst_n \
        tb_gpio.dut.u_core.pc \
        tb_gpio.dut.u_core.instr \
        tb_gpio.gpio_dout \
        tb_gpio.gpio_din

    simvision -submit window new WaveWindow -name "waveform"
    simvision -submit waveform using {waveform}
    simvision -submit waveform add -signals \
        tb_gpio.clk \
        tb_gpio.rst_n

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_gpio.dut.u_core.pc \
        tb_gpio.dut.u_core.instr

    simvision -submit waveform add -cdivider div
    simvision -submit waveform add -signals \
        tb_gpio.gpio_dout \
        tb_gpio.gpio_din
}

run
