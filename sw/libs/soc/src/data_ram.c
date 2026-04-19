#include <data_ram.h>
#include <memory_map.h>

#define SIZE    4096

void data_ram_write(uint32_t offset, uint32_t val)
{
    if (offset < SIZE)
        *((volatile uint32_t *)(DATA_RAM_BASE_ADDRESS + offset)) = val;

}

uint32_t data_ram_read(uint32_t offset)
{
    if (offset < SIZE)
        return *((volatile uint32_t *)(DATA_RAM_BASE_ADDRESS + offset));
    else
        return 0xdeadbeef;
}
