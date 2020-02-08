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

loop:	// read from PORT B in r6
	ldr		r0, [r6, GPIOx_IDR]

	// PB12: MREQ  PB13: IORQ  PB14: WR  PB15: RD

	// check for MREQ and RD
	tst		r0, 0b1001000000000000
	beq		read

	// check for MREQ and WR
	tst		r0, 0b0101000000000000
	bne		loop

write:	b		memaddr

	b		ready

read:

ready:	// set PA9 to indicate memory read is active
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

// Convert the contents of a PORTB read into a memory address
//
// Arguments
// 	r0: the raw value of PORTB
// Results
//	r0: the memory address in RAM or ROM
//	r1: set to 1 if the address is in ROM, else 0

	.extern		trs20_rom

	.equ		RAM_BASE, 0x20000000
	.equ		ROM_BASE, trs20_rom

	.type		memaddr, %function
memaddr:
	// the memory address is in PB0:1, 5:10
	movw		r2, 0b11111100
	and		r1, r2, r0, lsr 3	// put top 6 bits into r1

	and		r0, r0, 0b11		// assemble final address into r0
	orr		r0, r1, r0

	// check if RAM or ROM
	movw		r1, 1
	eors		r1, r1, r0, lsr 7

	ite		eq
	ldreq		r2, =RAM_BASE
	ldrne		r2, =ROM_BASE

	add		r0, r0, r2

	bx		lr

	.size		memaddr, . - memaddr

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
