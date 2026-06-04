#pragma once

#include <stdint.h>

void servo_enable(uint8_t enable);
void servo_set_inversion(uint8_t inversion);
void servo_set_scale(uint32_t scale);
void servo_set_target_pos(uint32_t position);
void servo_go_to(uint32_t position);
void servo_start_calibration(void);
void servo_wait_busy(void);
void servo_wait_go_to_done(void);
void servo_wait_calibration_done(void);

uint32_t servo_get_status(void);
uint32_t servo_get_target_pos(void);
uint32_t servo_get_current_pos(void);
uint8_t servo_is_busy(void);
uint8_t servo_is_sensor_active(void);
