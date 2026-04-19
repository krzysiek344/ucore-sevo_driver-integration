#pragma once

#include <stdint.h>

void data_ram_write(uint32_t offset, uint32_t val);
uint32_t data_ram_read(uint32_t offset);
