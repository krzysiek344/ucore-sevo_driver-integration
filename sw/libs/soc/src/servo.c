#include <servo.h>
#include <memory_map.h>
#include <reg.h>

#define SERVO_CR_ADDRESS          (SERVO_BASE_ADDRESS)
#define SERVO_SR_ADDRESS          (SERVO_BASE_ADDRESS + 0x004)
#define SERVO_TARGET_POS_ADDRESS  (SERVO_BASE_ADDRESS + 0x008)
#define SERVO_CURRENT_POS_ADDRESS (SERVO_BASE_ADDRESS + 0x00c)
#define SERVO_SCALE_ADDRESS       (SERVO_BASE_ADDRESS + 0x010)

#define SERVO_ENABLE_bm       0x1
#define SERVO_ENABLE_bp       0

#define SERVO_CALLIB_bm       0x2
#define SERVO_CALLIB_bp       1

#define SERVO_GO_TO_bm        0x4
#define SERVO_GO_TO_bp        2

#define SERVO_INVERSION_bm    0x8
#define SERVO_INVERSION_bp    3


void servo_set_enable(uint8_t en){

    reg_write_bits(SERVO_CR_ADDRESS, SERVO_ENABLE_bp, SERVO_ENABLE_bm, en);
}

void servo_set_inversion(uint8_t inv){

    reg_write_bits(SERVO_CR_ADDRESS, SERVO_INVERSION_bp, SERVO_INVERSION_bm, inv);
}

void servo_set_scale(uint32_t val){

    reg_write(SERVO_SCALE_ADDRESS, val);
}

void servo_callib(uint8_t en){

    reg_write_bits(SERVO_CR_ADDRESS, SERVO_CALLIB_bp, SERVO_CALLIB_bm, en);
}

void servo_go_to(uint32_t target_pos){

    reg_write(SERVO_TARGET_POS_ADDRESS, target_pos);
    reg_write_bits(SERVO_CR_ADDRESS, SERVO_GO_TO_bp, SERVO_GO_TO_bm, 1);
}

uint32_t servo_get_status(void){

    return reg_read(SERVO_SR_ADDRESS);
}

uint32_t servo_get_current_pos(void){

    return reg_read(SERVO_CURRENT_POS_ADDRESS);
}
