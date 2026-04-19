#include <soc/gpio.h>
#include <soc/timer.h>

int main()
{
    timer_set_enabled(1);

    for (int i = 0; i < 100; ++i)
        asm volatile ("nop");

    timer_set_enabled(0);
    gpio_set_dout(timer_get_value());

    while (1) { }
}
