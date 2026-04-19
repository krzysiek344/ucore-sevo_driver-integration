#pragma once

#include <stdint.h>

void uart_init(void);

uint8_t uart_read_byte(void);
int uart_read(char *dest, int len);

void uart_write_byte(uint8_t val);
void uart_write(const char *src);

void uart_flush(void);
