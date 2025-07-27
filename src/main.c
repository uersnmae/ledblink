#include "stm32f411xe.h"

void delay(volatile uint32_t count) {
	while (count--);
}

int main(void) {
	// 1 << 0 for GPIOA, 1 << 2 for GPIOC
	RCC->AHB1ENR |= (1 << 0) | (1 << 2);

	GPIOA->MODER &= ~(0b11 << 10); /* clear bits */
	GPIOA->MODER |=  (0b01 << 10); /* set output mode */

	GPIOC->MODER &= ~(0b11 << 26); /* clear bits, set input modt */

	while (1) {
		if ((GPIOC->IDR & (1 << 13)) == 0) {
			GPIOA->BSRR = (1 << 5);
		} else {
			GPIOA->BSRR = (1 << (5 + 16));
		}
	}
	return 0;
}
