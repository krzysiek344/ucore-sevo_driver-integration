#include <gpio.h>
#include <memory_map.h>
#include <reg.h>

#define GPIO_CR_ADDRESS (GPIO_BASE_ADDRESS + 0x000)
#define GPIO_SR_ADDRESS (GPIO_BASE_ADDRESS + 0x004)

void gpio_set_dout(uint32_t val)
{
    reg_write(GPIO_CR_ADDRESS, val);
}

uint32_t gpio_get_din(void)
{
    return reg_read(GPIO_SR_ADDRESS);
}
