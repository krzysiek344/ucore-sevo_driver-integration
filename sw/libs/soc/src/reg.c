#include <reg.h>

uint32_t reg_read(uint32_t address)
{
    return *((volatile uint32_t *)address);
}

uint32_t reg_read_bits(uint32_t address, uint8_t shift, uint32_t mask)
{
    return (reg_read(address) & mask) >> shift;
}

void reg_write(uint32_t address, uint32_t val)
{
    *((volatile uint32_t *)address) = val;
}

void reg_write_bits(uint32_t address, uint8_t shift, uint32_t mask, uint32_t val)
{
    auto rdata = reg_read(address);
    rdata &= ~mask;
    rdata |= (val << shift) & mask;
    reg_write(address, rdata);
}
