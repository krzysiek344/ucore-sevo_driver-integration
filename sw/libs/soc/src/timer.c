#include <timer.h>
#include <memory_map.h>
#include <reg.h>

#define TIMER_CR_ADDRESS (TIMER_BASE_ADDRESS + 0x000)
#define TIMER_SR_ADDRESS (TIMER_BASE_ADDRESS + 0x004)

#define TIMER_CR_EN_bm 0x1
#define TIMER_CR_EN_bp 0

void timer_set_enabled(uint8_t en)
{
    reg_write_bits(TIMER_CR_ADDRESS, TIMER_CR_EN_bp, TIMER_CR_EN_bm, en);
}

uint32_t timer_get_value(void)
{
    return reg_read(TIMER_SR_ADDRESS);
}
