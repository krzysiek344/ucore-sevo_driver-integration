#include <soc/gpio.h>

int main()
{
    while (1)
        gpio_set_dout(~gpio_get_din());
}
