#include <stdint.h>

#include <soc/servo.h>
#include <soc/uart.h>

#define TIMER_HZ        40000000u
#define SERVO_SCALE     (TIMER_HZ / 50u)      // 50 Hz

#define RX_BUF_LEN      32

static uint8_t starts_with(const char *s, const char *prefix)
{
    while (*prefix) {
        if (*s != *prefix)
            return 0;
        ++s;
        ++prefix;
    }
    return 1;
}

static uint8_t parse_u32(const char *s, uint32_t *val)
{
    uint32_t result = 0;
    uint8_t has_digit = 0;
    while (*s == ' ')
        ++s;
    while (*s >= '0' && *s <= '9') {
        has_digit = 1;
        result = result * 10u + (uint32_t)(*s - '0');
        ++s;
    }
    while (*s == ' ')
        ++s;
    if (*s != '\0')
        return 0;
    if (!has_digit)
        return 0;
    *val = result;
    return 1;
}

static void uart_write_u32(uint32_t val)
{
    char buf[11];
    int i = 0;
    if (val == 0) {
        uart_write_byte('0');
        return;
    }
    while (val > 0) {
        buf[i++] = (char)('0' + (val % 10u));
        val /= 10u;
    }
    while (i > 0)
        uart_write_byte((uint8_t)buf[--i]);
}

int main(void)
{
    char rx_buf[RX_BUF_LEN];

    uart_init();
    servo_set_enable(1);
    servo_set_inversion(0);
    servo_set_scale(SERVO_SCALE);

    uart_write("booted\n");

    while (1){

        if (uart_read(rx_buf, RX_BUF_LEN) != 0) continue;
    

        if (starts_with(rx_buf, "callib")){

            if (servo_is_busy()) {
                uart_write("ERR BUSY\n");
                continue;
            }
            servo_callib(1);
        }
        
        else if (starts_with(rx_buf, "goto ")){

            uint32_t target_pos;
            if (!parse_u32(rx_buf + 5, &target_pos)) {
                uart_write("ERR ARG\n");
                continue;
            }
            if (servo_is_busy()) {
                uart_write("ERR BUSY\n");
                continue;
            }
            servo_go_to(target_pos);
        }
        
        else if (starts_with(rx_buf, "pos?")){
            uart_write("POS: ");
            uart_write_u32(servo_get_current_pos());
            uart_write("\n");
        } 
        else if (starts_with(rx_buf, "status?")){
            if (servo_is_busy())
                uart_write("STATUS BUSY\n");
            else
                uart_write("STATUS IDLE\n");
        } 
        else{
            uart_write("ERR CMD\n");
        }
    }
}
