#include <soc/uart.h>

int main(void)
{
    uart_init();

    uart_write("sync\n");

    while (1)
        uart_write_byte(uart_read_byte());
}
