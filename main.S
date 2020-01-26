	.thumb
	.syntax		unified
	.cpu		cortex-m4
.equ		GPIOA, 0x40020000
	.equ		GPIOB, 0x40020400
	.equ		GPIOC, 0x40020800
	.equ		GPIOD, 0x40020C00

	.equ		GPIOx_MODER, 0x00
	.equ		GPIOx_OTYPER, 0x04
	.equ		GPIOx_OSPEEDR, 0x08
	.equ		GPIOx_PUPDR, 0x0C
	.equ		GPIOx_IDR, 0x10
	.equ		GPIOx_ODR, 0x14
	.equ		GPIOx_BSRR, 0x18
	.equ		GPIOx_LCKR, 0x1C
	.equ		GPIOx_AFRL, 0x20
	.equ		GPIOx_AFRH, 0x24

	.equ		RCC, 0x40023800
	.equ		RCC_CR, 0x00
	.equ		RCC_PLLCFGR, 0x04
	.equ		RCC_CFGR, 0x08
	.equ		RCC_CIR, 0x0C
	.equ		RCC_AHB1RSTR, 0x10
	.equ		RCC_AHB2RSTR, 0x14
	.equ		RCC_APB1RSTR, 0x20
	.equ		RCC_APB2RSTR, 0x20
	.equ		RCC_AHB1ENR, 0x30
	.equ		RCC_AHB2ENR, 0x34
	.equ		RCC_APB1ENR, 0x40
	.equ		RCC_APB2ENR, 0x44
	.equ		RCC_AHB1LPENR, 0x50
	.equ		RCC_AHB2LPENR, 0x54
	.equ		RCC_APB1LPENR, 0x60
	.equ		RCC_APB2LPENR, 0x64
	.equ		RCC_BDCR, 0x70
	.equ		RCC_CSR, 0x74
	.equ		RCC_SSCGR, 0x80
	.equ		RCC_PLLI2SCFGR, 0x84
	.equ		RCC_DCKCFGR, 0x8C

	.equ		RCC_CR_HSEON, 1 << 16
	.equ		RCC_CR_HSERDY, 1 << 17

	.equ		RCC_APB1ENR_PWREN, 1 << 28

.section	.text.vectors

vectors:
@ Vector table start
	.long		0x20010000	// stack
	.long		_start		// reset
	.long		_error		// NMI
	.long		_error		// hard fault
	.long		_error		// memory fault
	.long		_error		// bus fault
	.long		_error		// usage fault
@ Vector table end

.section	.text.start

	.global		_start
	//.thumb_func
	.type _start, %function
_start:
	// FPU coprocessor is off at reset, CPACR
	// enable APB1 clock
	ldr		r6, =RCC
	ldr		r0, [r6, RCC_APB1ENR]
	orr		r0, r0, RCC_APB1ENR_PWREN
	str		r0, [r6, RCC_APB1ENR]
	ldr		r0, [r6, RCC_APB1ENR]		// read register back 

	// AHB1 clock for GPIOAEN, GPIOBEN
	// APB1 clock 

	// Enable HSE
	ldr		r0, [r6, RCC_CR]
	orr		r0, r0, RCC_CR_HSEON
	str		r0, [r6, RCC_CR]
	ldr		r0, [r6, RCC_CR]

	// Wait for HSE to be ready
hsewait:
	ldr		r0, [r6, RCC_CR]
	and		r0, r0, RCC_CR_HSERDY

loop:
	add		r0, r0, #1
	b		loop

.section	.text.error

	.type _error, %function
_error:
	b		_error+1

.section	.data.rom

rom:
	.long	0xdeadbeef
