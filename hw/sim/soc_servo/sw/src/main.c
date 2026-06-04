#include <soc/servo.h>

int main(void)
{
    // init
    servo_set_enable(1);
    servo_set_inversion(0);
    servo_set_scale(2);

    // test
    servo_go_to(3);

    while(1) 
    {}
}