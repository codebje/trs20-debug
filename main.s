	.thumb
	.syntax		unified
	.cpu		cortex-m4

	.include	"include/stm32f401.s"

	// PB12: MREQ  PB13: IORQ  PB14: WR  PB15: RD
	.equ		MREQ,	0b0001000000000000
	.equ		IORQ,	0b0010000000000000
	.equ		WR,	0b0100000000000000
	.equ		RD,	0b1000000000000000

	// GPIOA_MODER half-word values for input/output modes
	.equ		MODER_INPUT, 0b0000000000000000
	.equ		MODER_OUTPUT, 0b0101010101010101

.section	.text.main

	.global		main
	.type main, %function
main:	bl		hwinit

	ldr		r5, =GPIOA
	ldr		r6, =GPIOB

idle:	// read from PORT B in r6
	ldr		r0, [r6, GPIOx_IDR]

	// mask out and negate active-low signals
	mvn		r4, r0
	ands		r4, r4, MREQ | IORQ | RD | WR

	// if none are set, go back and try again
	beq		idle

	// IORQ is NYI
	tst		r4, IORQ
	bne		idle

	// translate memory address
	bl		memaddr

	cmp		r4, MREQ | RD
	beq		memread

	cmp		r4, MREQ | WR
	beq		memwrite

	// insufficient signals asserted, go back and wait more
	b		idle

memread:
	// read a byte and write it to PA0:7
	ldrb		r1, [r0]
	strb		r1, [r5, GPIOx_ODR]

	// set PA0:7 to OUTPUT
	ldr		r1, =MODER_OUTPUT
	strh		r1, [r5, GPIOx_MODER]

	b		ready

memwrite:
	// read a byte from PA0:7
	ldrb		r2, [r5, GPIOx_IDR]

	// write it only if the destination is in RAM
	cmp		r1, #1
	it		ne
	strbne		r2, [r0]

	// fall through to ready:

ready:	// set PA9 to indicate request is being serviced
	ldr		r0, =1 << 9
	str		r0, [r5, GPIOx_BSRR]

reading:// wait for all signals to go inactive
	ldr		r0, [r6, GPIOx_IDR]
	mvn		r0, r0
	ands		r0, r0, MREQ | IORQ | RD | WR
	bne		reading

	// set PA0:7 to INPUT
	ldr		r1, =MODER_INPUT
	strh		r1, [r5, GPIOx_MODER]

	// reset PA9
	ldr		r0, =1 << 25
	str		r0, [r5, GPIOx_BSRR]

	// go back and wait for next bus cycle
	b		idle

	.size 		main, . - main

// Initialise peripherals.
// No arguments, no return.

	.type		hwinit, %function

hwinit:
	// enable GPIOA, GPIOB, GPIOC clocks
	ldr		r2, =RCC
	ldr		r0, [r2, RCC_AHB1ENR]
	orr		r0, r0, RCC_AHB1ENR_GPIOAEN | RCC_AHB1ENR_GPIOBEN | RCC_AHB1ENR_GPIOCEN
	str		r0, [r2, RCC_AHB1ENR]
	ldr		r0, [r2, RCC_AHB1ENR]		// read register back 

	// switch PA0:7, 9 to very high speed
	ldr		r2, =GPIOA
	ldr		r0, [r2, GPIOx_OSPEEDR]
	ldr		r1, =0b11001111111111111111
	orr		r0, r0, r1
	str		r0, [r2, GPIOx_OSPEEDR]

	// set PA9 mode output, push-pull, no pull-up/down
	ldr		r0, [r2, GPIOx_MODER]
	orr		r0, r0, GPIOx_MODER_MODE_OUTPUT << 18
	str		r0, [r2, GPIOx_MODER]

	// configure PC13 as output, push-pull, no pup/pd
	ldr		r2, =GPIOC
	ldr		r0, =GPIOx_MODER_MODE_OUTPUT << 26
	str		r0, [r2, GPIOx_MODER]

	bx		lr

	.size		hwinit, . - hwinit

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

	// check if RAM or ROM, and leave 0 or 1 in r1
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
