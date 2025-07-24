#include "stm32f411xe.h"

void delay(volatile uint32_t count) {
	while (count--);
}

int main(void) {
	RCC->AHB1ENR |= (1 << 0);

	GPIOA->MODER &= ~(0b11 << 10);
	GPIOA->MODER |=  (0b01 << 10);

	while (1) {
		GPIOA->BSRR = (1 << 5);
		delay(500000);

		GPIOA->BSRR = (1 << (5 + 16));
		delay(500000);
	}
	return 0;
}
