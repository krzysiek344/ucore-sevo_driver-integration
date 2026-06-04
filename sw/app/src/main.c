// TODO
// na razie nie przejmujemy sie tym dopuki robimy symulacje
#include <stdint.h>

#include <soc/servo.h>
#include <soc/uart.h>

#define SERVO_SCALE          400000u
#define SERVO_POS_A         0u
#define SERVO_POS_B         100u
#define MOVE_DELAY_CYCLES   1000000u

static void delay_cycles(uint32_t cycles)
{
    for (uint32_t i = 0; i < cycles; ++i)
        asm volatile ("nop");
}

int main(void)
{
    uart_init();
    uart_write("servo demo\n");

    servo_set_scale(SERVO_SCALE);
    servo_set_inversion(0);
    servo_enable(1);

    while (1) {
        servo_go_to(SERVO_POS_B);
        servo_wait_go_to_done();
        uart_write("position B\n");
        delay_cycles(MOVE_DELAY_CYCLES);

        servo_go_to(SERVO_POS_A);
        servo_wait_go_to_done();
        uart_write("position A\n");
        delay_cycles(MOVE_DELAY_CYCLES);
    }
}
