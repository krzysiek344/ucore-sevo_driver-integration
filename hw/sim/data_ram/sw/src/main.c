#include <soc/data_ram.h>

int main(void)
{
    for (int i = 0; i < 1024; ++i)
        data_ram_write(i * 4, i);

    while (1) { }
}
