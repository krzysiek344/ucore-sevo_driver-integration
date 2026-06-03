#include <soc/servo.h>

int main(void)
{
    // init
    servo_set_enable();
    servo_set_inversion();
    servo_set_scale();

    // test
    servo_go_to(3);

    while(1) 
    {}
}