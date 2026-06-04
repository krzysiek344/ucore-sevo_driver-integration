#pragma once

#include <stdint.h>

void servo_set_enable(uint8_t en);
void servo_set_inversion(uint8_t inv);
void servo_set_scale(uint32_t val);

void servo_callib(uint8_t en);
void servo_go_to(uint32_t target_pos);

uint32_t servo_get_status(void);
uint32_t servo_get_current_pos(void);
uint32_t servo_get_target_pos(void);

uint8_t servo_is_busy(void);
uint8_t servo_is_sensor_active(void);
