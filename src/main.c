#include "nrf_delay.h"
#include "nrf_gpio.h"

int main(void){
	nrf_gpio_range_cfg_output(18, 19);

	while(1){
		nrf_gpio_port_write(2, 8);
		nrf_delay_ms(500);

		nrf_gpio_port_write(2, 4);
		nrf_delay_ms(500);
	}
}
