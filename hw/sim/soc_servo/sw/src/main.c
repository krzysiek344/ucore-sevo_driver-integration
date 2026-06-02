#include <soc/reg.h>

#define SERVO_BASE_ADDRESS       0x50000000

#define SERVO_CR_ADDRESS         (SERVO_BASE_ADDRESS + 0x000)
#define SERVO_TARGET_POS_ADDRESS (SERVO_BASE_ADDRESS + 0x008)
#define SERVO_SCALE_ADDRESS      (SERVO_BASE_ADDRESS + 0x010)

#define SERVO_CR_ENABLE_bm       0x1
#define SERVO_CR_GO_TO_bm        0x4

int main(void)
{
    reg_write(SERVO_SCALE_ADDRESS, 2);
    reg_write(SERVO_TARGET_POS_ADDRESS, 3);
    reg_write(SERVO_CR_ADDRESS, SERVO_CR_ENABLE_bm | SERVO_CR_GO_TO_bm);

    while(1) 
    {}
}