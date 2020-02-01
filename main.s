	.thumb
	.syntax		unified
	.cpu		cortex-m4

	.include	"include/stm32f401.s"

.section	.text.main

	.global		main
	//.thumb_func
	.type main, %function
main:
	// enable GPIOA, GPIOB, GPIOC clocks
	ldr		r6, =RCC
	ldr		r0, [r6, RCC_AHB1ENR]
	orr		r0, r0, RCC_AHB1ENR_GPIOAEN | RCC_AHB1ENR_GPIOBEN | RCC_AHB1ENR_GPIOCEN
	str		r0, [r6, RCC_AHB1ENR]
	ldr		r0, [r6, RCC_AHB1ENR]		// read register back 

	// Enable TIM2, TIM9
	ldr		r0, [r6, RCC_APB1ENR]
	orr		r0, r0, 1
	str		r0, [r6, RCC_APB1ENR]
	ldr		r0, [r6, RCC_APB1ENR]
	ldr		r0, [r6, RCC_APB2ENR]
	orr		r0, r0, 1 << 16
	str		r0, [r6, RCC_APB2ENR]
	ldr		r0, [r6, RCC_APB2ENR]

	// Configure PA2 for AF01, TIM2_CH3.
	ldr		r6, =GPIOA

	// PA2 resets as no pull-up/pull-down, output mode push-pull.
	// Need to set output speed (vhigh for fast edges), AF01 for TIM2_CH3, and mode AF.

	ldr		r0, = GPIOx_OSPEEDR_VHIGH << GPIOx_OSPEEDR2
	str		r0, [r6, GPIOx_OSPEEDR]		// set PA2 to very high speed

	ldr		r0, = 1 << GPIOx_AFRL_AFRL2
	str		r0, [r6, GPIOx_AFRL]		// set AF01 for PA2

	ldr		r0, [r6, GPIOx_MODER]
	orr		r0, r0, GPIOx_MODER_MODE_ALT << 4
	str		r0, [r6, GPIOx_MODER]		// set PA2 to mode AF, PA0 to OUTPUT

	// Configure TIM2 to emit a 1MHz signal
	ldr		r6, =TIM2

	ldr		r0, =6
	str		r0, [r6, TIMx_PSC]

	ldr		r0, =5
	str		r0, [r6, TIMx_ARR]

	// Enable PWM Mode 1 with a 50% duty cycle
	ldr		r0, =TIMx_CCMR_OCxM_PWM_1 << TIMx_CCMR2_OC3M_OFFSET
	str		r0, [r6, TIMx_CCMR2]
	ldr		r0, =3				// 50% duty cycle
	str		r0, [r6, TIMx_CCR3]
	ldr		r0, =TIMx_CCER_CC3E		// enable channel 3
	str		r0, [r6, TIMx_CCER]

	// Reload all registers from preloads
	ldr		r0, =TIMx_EGR_UG
	str		r0, [r6, TIMx_EGR]

	// Enable the timer
	ldr		r0, =TIMx_CR1_CEN
	str		r0, [r6, TIMx_CR1]

	// configure PC13 as output, push-pull, no pup/pd
	ldr		r6, =GPIOC
	ldr		r0, =GPIOx_MODER_MODE_OUTPUT << 26
	str		r0, [r6, GPIOx_MODER]

loop:	// loop forever
	add		r0, r0, #1
	b		loop

	.size 		main, . - main
