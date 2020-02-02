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

	// switch PA0:7, 9 to very high speed
	ldr		r5, =GPIOA
	ldr		r0, [r5, GPIOx_OSPEEDR]
	ldr		r1, =0b11001111111111111111
	orr		r0, r0, r1
	str		r0, [r5, GPIOx_OSPEEDR]

	// set PA9 mode output, push-pull, no pull-up/down
	ldr		r0, [r5, GPIOx_MODER]
	orr		r0, r0, GPIOx_MODER_MODE_OUTPUT << 18
	str		r0, [r5, GPIOx_MODER]

	// configure PC13 as output, push-pull, no pup/pd
	ldr		r6, =GPIOC
	ldr		r0, =GPIOx_MODER_MODE_OUTPUT << 26
	str		r0, [r6, GPIOx_MODER]

	ldr		r6, =GPIOB

loop:	// wait for MREQ and RD to be set
	ldr		r0, [r6, GPIOx_IDR]
	ands		r1, r0, 0b1010000000000000
	beq		loop

	// set PA9 to indicate memory read is active
	ldr		r0, =1 << 9
	str		r0, [r5, GPIOx_BSRR]

reading:// wait for MREQ and RD to go inactive
	ldr		r0, [r6, GPIOx_IDR]
	ands		r1, r0, 0b1010000000000000
	bne		reading

	// reset PA9
	ldr		r0, =1 << 25
	str		r0, [r5, GPIOx_BSRR]

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
