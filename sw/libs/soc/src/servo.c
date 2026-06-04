#include <servo.h>
#include <memory_map.h>
#include <reg.h>

#define SERVO_CR_ADDRESS          (SERVO_BASE_ADDRESS + 0x000)
#define SERVO_SR_ADDRESS          (SERVO_BASE_ADDRESS + 0x004)
#define SERVO_TARGET_POS_ADDRESS  (SERVO_BASE_ADDRESS + 0x008)
#define SERVO_CURRENT_POS_ADDRESS (SERVO_BASE_ADDRESS + 0x00c)
#define SERVO_SCALE_ADDRESS       (SERVO_BASE_ADDRESS + 0x010)

#define SERVO_CR_ENABLE_bp        0
#define SERVO_CR_ENABLE_bm        (0x1 << SERVO_CR_ENABLE_bp)
#define SERVO_CR_CALLIB_bp        1
#define SERVO_CR_CALLIB_bm        (0x1 << SERVO_CR_CALLIB_bp)
#define SERVO_CR_GO_TO_bp         2
#define SERVO_CR_GO_TO_bm         (0x1 << SERVO_CR_GO_TO_bp)
#define SERVO_CR_INVERSION_bp     3
#define SERVO_CR_INVERSION_bm     (0x1 << SERVO_CR_INVERSION_bp)

#define SERVO_SR_CALLIB_DONE_bp   0
#define SERVO_SR_CALLIB_DONE_bm   (0x1 << SERVO_SR_CALLIB_DONE_bp)
#define SERVO_SR_GO_TO_DONE_bp    1
#define SERVO_SR_GO_TO_DONE_bm    (0x1 << SERVO_SR_GO_TO_DONE_bp)
#define SERVO_SR_BUSY_bp          2
#define SERVO_SR_BUSY_bm          (0x1 << SERVO_SR_BUSY_bp)
#define SERVO_SR_SENSOR_RAW_bp    3
#define SERVO_SR_SENSOR_RAW_bm    (0x1 << SERVO_SR_SENSOR_RAW_bp)

static uint32_t servo_get_cr(void);
static void servo_set_cr(uint32_t val);

void servo_enable(uint8_t enable)
{
    uint32_t cr = servo_get_cr();

    if (enable)
        cr |= SERVO_CR_ENABLE_bm;
    else
        cr &= ~(SERVO_CR_ENABLE_bm | SERVO_CR_CALLIB_bm | SERVO_CR_GO_TO_bm);

    servo_set_cr(cr);
}

void servo_set_inversion(uint8_t inversion)
{
    uint32_t cr = servo_get_cr();

    if (inversion)
        cr |= SERVO_CR_INVERSION_bm;
    else
        cr &= ~SERVO_CR_INVERSION_bm;

    servo_set_cr(cr);
}

void servo_set_scale(uint32_t scale)
{
    if (!scale)
        scale = 1;

    reg_write(SERVO_SCALE_ADDRESS, scale);
}

void servo_set_target_pos(uint32_t position)
{
    reg_write(SERVO_TARGET_POS_ADDRESS, position);
}

void servo_go_to(uint32_t position)
{
    uint32_t cr;

    servo_set_target_pos(position);

    cr = servo_get_cr();
    cr |= SERVO_CR_ENABLE_bm | SERVO_CR_GO_TO_bm;
    cr &= ~SERVO_CR_CALLIB_bm;

    servo_set_cr(cr);
}

void servo_start_calibration(void)
{
    uint32_t cr = servo_get_cr();

    cr |= SERVO_CR_ENABLE_bm | SERVO_CR_CALLIB_bm;
    cr &= ~SERVO_CR_GO_TO_bm;

    servo_set_cr(cr);
}

void servo_wait_busy(void)
{
    while (servo_is_busy()) { }
}

void servo_wait_go_to_done(void)
{
    while (!(servo_get_status() & SERVO_SR_GO_TO_DONE_bm)) { }
}

void servo_wait_calibration_done(void)
{
    while (!(servo_get_status() & SERVO_SR_CALLIB_DONE_bm)) { }
}

uint32_t servo_get_status(void)
{
    return reg_read(SERVO_SR_ADDRESS);
}

uint32_t servo_get_target_pos(void)
{
    return reg_read(SERVO_TARGET_POS_ADDRESS);
}

uint32_t servo_get_current_pos(void)
{
    return reg_read(SERVO_CURRENT_POS_ADDRESS);
}

uint8_t servo_is_busy(void)
{
    return (servo_get_status() & SERVO_SR_BUSY_bm) ? 1 : 0;
}

uint8_t servo_is_sensor_active(void)
{
    return (servo_get_status() & SERVO_SR_SENSOR_RAW_bm) ? 1 : 0;
}

static uint32_t servo_get_cr(void)
{
    return reg_read(SERVO_CR_ADDRESS);
}

static void servo_set_cr(uint32_t val)
{
    reg_write(SERVO_CR_ADDRESS, val);
}
