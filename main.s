	.thumb
	.syntax		unified
	.cpu		cortex-m4

	.include	"include/stm32f401.s"

.section	.text.main

	.global		main
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

	// Configure PA1 for AF01, TIM2_CH2, and PA3 for AF03, TIM9_CH2
	ldr		r6, =GPIOA

	// PA1/3 reset as no pull-up/pull-down, output mode push-pull.
	// Need to set output speed, select AF, and set AF mode

	ldr		r0, = GPIOx_OSPEEDR_VHIGH << GPIOx_OSPEEDR1 | GPIOx_OSPEEDR_VHIGH << GPIOx_OSPEEDR3
	str		r0, [r6, GPIOx_OSPEEDR]		// set PA1/3 to very high speed

	ldr		r0, = 1 << GPIOx_AFRL_AFRL1 | 3 << GPIOx_AFRL_AFRL3
	str		r0, [r6, GPIOx_AFRL]		// set AF01 for PA1, AF03 for PA3

	ldr		r0, [r6, GPIOx_MODER]
	orr		r0, r0, GPIOx_MODER_MODE_ALT << 2 | GPIOx_MODER_MODE_ALT << 6
	str		r0, [r6, GPIOx_MODER]		// set AF for PA1, PA3

	// Configure TIM2 to emit a 1MHz signal
	ldr		r0, =TIM2
	ldr		r1, =6
	ldr		r2, =5
	bl		tim_ch2

	// Configure TIM9 to also emit a 1MHz signal
	ldr		r0, =TIM9
	ldr		r1, =6
	ldr		r2, =5
	bl		tim_ch2

	// configure PC13 as output, push-pull, no pup/pd
	ldr		r6, =GPIOC
	ldr		r0, =GPIOx_MODER_MODE_OUTPUT << 26
	str		r0, [r6, GPIOx_MODER]

loop:	// loop forever
	add		r0, r0, #1
	b		loop

	.size 		main, . - main

// Configure a timer to emit a square wave. This is fixed to channel 2 and
// expects the timer to be in its reset condition.
//
// r0: the timer's base address
// r1: the prescaler
// r2: the auto-reload counter
	.global		tim_ch2
	.type tim_ch2, %function
tim_ch2:
	str		r1, [r0, TIMx_PSC]
	str		r2, [r0, TIMx_ARR]

	// Half of the reload time needs to go in CCR2 for 50% duty cycle
	add		r2, r2, 1
	lsr		r2, 1
	str		r2, [r0, TIMx_CCR2]

	// Enable PWM Mode 1 with a 50% duty cycle
	ldr		r1, =TIMx_CCMR_OCxM_PWM_1 << TIMx_CCMR1_OC2M_OFFSET
	str		r1, [r0, TIMx_CCMR1]
	ldr		r1, =TIMx_CCER_CC2E		// enable channel 2
	str		r1, [r0, TIMx_CCER]

	// Reload all registers from preloads
	ldr		r1, =TIMx_EGR_UG
	str		r1, [r0, TIMx_EGR]

	// Enable the timer
	ldr		r1, =TIMx_CR1_CEN
	str		r1, [r0, TIMx_CR1]

	bx		lr

	.size		tim_ch2, . - tim_ch2
