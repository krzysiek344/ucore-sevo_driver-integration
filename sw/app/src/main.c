#include <stdint.h>

#include <soc/gpio.h>
#include <soc/servo.h>

#define TIMER_HZ        40000000u
#define SERVO_SCALE     (TIMER_HZ / 50u)      // 50 Hz

int main(void)
{
        servo_set_enable(1);
        servo_set_inversion(0);
        servo_set_scale(SERVO_SCALE);

        uint32_t prev_gpio = 0;
        uint32_t curr_gpio;

        uint8_t sw0_curr;
        uint8_t sw0_prev;
        uint8_t sw1_curr;
        uint8_t sw1_prev;

        while(1)
        {
                curr_gpio = gpio_get_din();

                sw0_curr = (curr_gpio & 0x01) ? 1 : 0;
                sw1_curr = (curr_gpio & 0x02) ? 1 : 0;

                sw0_prev = (prev_gpio & 0x01) ? 1 : 0;
                sw1_prev = (prev_gpio & 0x02) ? 1 : 0;

                if(sw0_curr == 1 && sw0_prev == 0){

                       if(!servo_is_busy())  servo_callib(1);
                }

                if(sw1_curr == 1 && sw1_prev == 0){

                        if(!servo_is_busy()) servo_go_to(20);
                }

                prev_gpio = curr_gpio;
        }
}
