	.thumb
	.syntax		unified
	.cpu		cortex-m4

	.include	"include/stm32f401.s"

.macro	mov32 reg, val
	movw	\reg, #:lower16:\val
	movt	\reg, #:upper16:\val
.endm

.section	.text.start

	// Clock configuration: APB2 = /1, APB1 = /2, AHB = /1, SW = 0 (HSI)
	.equ		CLOCK_CONFIG, 0b100 << RCC_CFGR_PPRE1_OFFSET

	// PLL configuration: 25MHz crystal / 25 * 336 / 7 = 48, 336 / 4 = 84
	.equ		PLL_CONFIG_P, RCC_PLLCFGR_PLLP_4
	.equ		PLL_CONFIG_Q, 7 << RCC_PLLCFGR_PLLQ_OFFSET
	.equ		PLL_CONFIG_M, 25 << RCC_PLLCFGR_PLLM_OFFSET
	.equ		PLL_CONFIG_N, 336 << RCC_PLLCFGR_PLLN_OFFSET
	.equ		PLL_CONFIG_SRC, RCC_PLLCFGR_PLLSRC_HSE
	.equ		PLL_CONFIG, PLL_CONFIG_P | PLL_CONFIG_Q | PLL_CONFIG_M | PLL_CONFIG_N | PLL_CONFIG_SRC

	// Flash configuration: two wait states, instruction and data caches enabled, prefetch on
	.equ		FLASH_CONFIG, FLASH_ACR_PRFTEN | FLASH_ACR_ICEN | FLASH_ACR_DCEN | 2

	.global		_start
	//.thumb_func
	.type _start, %function
_start:
	ldr		r6, =RCC

	// Configure prescalers: AHB=1, APB1=2, APB2=1
	// The APB1 should never exceed 42MHz, and it can take up to 16 AHB cycles for this setting
	// to come into effect. The prescalers are configured here to give them time to change while
	// the PLL is configured.
	movw		r0, CLOCK_CONFIG	// leave top 16 bits zero
	str		r0, [r6, RCC_CFGR]

	// Configure Flash wait states and accelerations. This must be done before selecting the PLL
	// as a clock source. The manual doesn't specify any delays before this takes effect, but
	// there is no harm in doing it before configuring the PLL.
	ldr		r5, =FLASH
	mov		r0, FLASH_CONFIG
	//strh		r0, [r5, FLASH_ACR]

	// Enable HSE
	ldr		r0, [r6, RCC_CR]
	orr		r0, r0, RCC_CR_HSEON
	str		r0, [r6, RCC_CR]

hsewait:// Wait for HSE to be ready
	ldr		r0, [r6, RCC_CR]
	ands		r0, r0, RCC_CR_HSERDY
	bne		hsewait

	// Configure the PLL
	mov32		r0, PLL_CONFIG
	//str		r0, [r6, RCC_PLLCFGR]

	// Enable the PLL
	ldr		r0, [r6, RCC_CR]
	orr		r0, r0, RCC_CR_PLLON
	//str		r0, [r6, RCC_CR]

pllwait:// Wait for PLL to be ready
	ldr		r0, [r6, RCC_CR]
	ands		r0, r0, RCC_CR_PLLRDY
	//bne		pllwait

	// Select the PLL as the system clock source
	movw		r0, CLOCK_CONFIG | RCC_CFGR_SW_PLL
	//str		r0, [r6, RCC_CFGR]

clkwait:// Wait for SYSCLK to be ready
	ldr		r0, [r6, RCC_CFGR]
	and		r0, r0, RCC_CFGR_SWS_MASK
	cmp		r0, RCC_CFGR_SWS_PLL
	//bne		clkwait

	b		main

	.size 		_start, . - _start
