#pragma once

#include <stdint.h>

uint32_t reg_read(uint32_t address);
uint32_t reg_read_bits(uint32_t address, uint8_t shift, uint32_t mask);

void reg_write(uint32_t address, uint32_t val);
void reg_write_bits(uint32_t address, uint8_t shift, uint32_t mask, uint32_t val);
