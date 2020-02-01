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

	.equ		GPIOx_MODER_MODE_INPUT, 0b00
	.equ		GPIOx_MODER_MODE_OUTPUT, 0b01
	.equ		GPIOx_MODER_MODE_ALT, 0b10
	.equ		GPIOx_MODER_MODE_ANALOG, 0b11

	.equ		GPIOx_OSPEEDR_LOW, 0b00
	.equ		GPIOx_OSPEEDR_MEDIUM, 0b01
	.equ		GPIOx_OSPEEDR_HIGH, 0b10
	.equ		GPIOx_OSPEEDR_VHIGH, 0b11

	.equ		GPIOx_OSPEEDR0, 0
	.equ		GPIOx_OSPEEDR1, 2
	.equ		GPIOx_OSPEEDR2, 4
	.equ		GPIOx_OSPEEDR3, 6
	.equ		GPIOx_OSPEEDR4, 8
	.equ		GPIOx_OSPEEDR5, 10
	.equ		GPIOx_OSPEEDR6, 12
	.equ		GPIOx_OSPEEDR7, 14
	.equ		GPIOx_OSPEEDR8, 16
	.equ		GPIOx_OSPEEDR9, 18
	.equ		GPIOx_OSPEEDR10, 20
	.equ		GPIOx_OSPEEDR11, 22
	.equ		GPIOx_OSPEEDR12, 24
	.equ		GPIOx_OSPEEDR13, 26
	.equ		GPIOx_OSPEEDR14, 28
	.equ		GPIOx_OSPEEDR15, 30

	.equ		GPIOx_AFRL_AFRL0, 0
	.equ		GPIOx_AFRL_AFRL1, 4
	.equ		GPIOx_AFRL_AFRL2, 8
	.equ		GPIOx_AFRL_AFRL3, 12
	.equ		GPIOx_AFRL_AFRL4, 16
	.equ		GPIOx_AFRL_AFRL5, 20
	.equ		GPIOx_AFRL_AFRL6, 24
	.equ		GPIOx_AFRL_AFRL7, 28

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

	// RCC Control Register values
	.equ		RCC_CR_HSEON, 1 << 16
	.equ		RCC_CR_HSERDY, 1 << 17
	.equ		RCC_CR_PLLON, 1 << 24
	.equ		RCC_CR_PLLRDY, 1 << 25

	// RCC PLL Configuration Register bit offsets
	.equ		RCC_PLLCFGR_PLLM_OFFSET, 0
	.equ		RCC_PLLCFGR_PLLN_OFFSET, 6
	.equ		RCC_PLLCFGR_PLLP_OFFSET, 16
	.equ		RCC_PLLCFGR_PLLSRC_OFFSET, 22
	.equ		RCC_PLLCFGR_PLLQ_OFFSET, 24

	// RCC PLL Configuration Register values
	.equ		RCC_PLLCFGR_PLLSRC_HSI, 0b0 << RCC_PLLCFGR_PLLSRC_OFFSET
	.equ		RCC_PLLCFGR_PLLSRC_HSE, 0b1 << RCC_PLLCFGR_PLLSRC_OFFSET
	.equ		RCC_PLLCFGR_PLLP_2, 0b00 << RCC_PLLCFGR_PLLP_OFFSET
	.equ		RCC_PLLCFGR_PLLP_4, 0b01 << RCC_PLLCFGR_PLLP_OFFSET
	.equ		RCC_PLLCFGR_PLLP_6, 0b10 << RCC_PLLCFGR_PLLP_OFFSET
	.equ		RCC_PLLCFGR_PLLP_8, 0b11 << RCC_PLLCFGR_PLLP_OFFSET

	// RCC Clock Configuration Register values
	.equ		RCC_CFGR_SW_OFFSET, 0
	.equ		RCC_CFGR_SWS_OFFSET, 2
	.equ		RCC_CFGR_HPRE_OFFSET, 4
	.equ		RCC_CFGR_PPRE1_OFFSET, 10
	.equ		RCC_CFGR_PPRE2_OFFSET, 13

	.equ		RCC_CFGR_HPRE_MASK, 15 << RCC_CFGR_HPRE_OFFSET
	.equ		RCC_CFGR_PPRE1_MASK, 7 << RCC_CFGR_PPRE1_OFFSET
	.equ		RCC_CFGR_PPRE2_MASK, 7 << RCC_CFGR_PPRE2_OFFSET

	.equ		RCC_CFGR_SW_HSI, 0b00
	.equ		RCC_CFGR_SW_HSE, 0b01
	.equ		RCC_CFGR_SW_PLL, 0b10

	.equ		RCC_CFGR_SWS_MASK, 0b11 << RCC_CFGR_SWS_OFFSET
	.equ		RCC_CFGR_SWS_HSI, 0b00 << RCC_CFGR_SWS_OFFSET
	.equ		RCC_CFGR_SWS_HSE, 0b01 << RCC_CFGR_SWS_OFFSET
	.equ		RCC_CFGR_SWS_PLL, 0b10 << RCC_CFGR_SWS_OFFSET

	// RCC AHB1 Enable Register values
	.equ		RCC_AHB1ENR_GPIOAEN, 1 << 0
	.equ		RCC_AHB1ENR_GPIOBEN, 1 << 1
	.equ		RCC_AHB1ENR_GPIOCEN, 1 << 2

	// RCC APB1 Enable Register values
	.equ		RCC_APB1ENR_PWREN, 1 << 28

	// RCC APB2 Enable Register values
	.equ		RCC_APB2ENR_SYSCFGEN, 1 << 14

	.equ		FLASH, 0x40023C00
	.equ		FLASH_ACR, 0x00

	// Flash Accesss Control Register values
	.equ		FLASH_ACR_PRFTEN, 1 << 8
	.equ		FLASH_ACR_ICEN, 1 << 9
	.equ		FLASH_ACR_DCEN, 1 << 10

	// Timer registers
	.equ		TIM2, 0x40000000
	.equ		TIM9, 0x40014000

	.equ		TIMx_CR1, 0x00
	.equ		TIMx_EGR, 0x14
	.equ		TIMx_CCMR1, 0x18
	.equ		TIMx_CCMR2, 0x1C
	.equ		TIMx_CCER, 0x20
	.equ		TIMx_PSC, 0x28
	.equ		TIMx_ARR, 0x2C
	.equ		TIMx_CCR1, 0x34
	.equ		TIMx_CCR2, 0x38
	.equ		TIMx_CCR3, 0x3C
	.equ		TIMx_CCR4, 0x40

	// General timer values
	.equ		TIMx_CR1_CEN, 1 << 0

	.equ		TIMx_CCMR_OCxM_FROZEN, 0b000		// CCRx has no effect on output
	.equ		TIMx_CCMR_OCxM_ACTIVE, 0b001		// Output set active on match
	.equ		TIMx_CCMR_OCxM_INACTIVE, 0b010		// Output set inactive on match
	.equ		TIMx_CCMR_OCxM_TOGGLE, 0b011		// Output toggled on match
	.equ		TIMx_CCMR_OCxM_FORCE_INACTIVE, 0b100	// Output forced inactive
	.equ		TIMx_CCMR_OCxM_FORCE_ACTIVE, 0b101	// Output forced active
	.equ		TIMx_CCMR_OCxM_PWM_1, 0b110		// PWM mode 1
	.equ		TIMx_CCMR_OCxM_PWM_2, 0b111		// PWM mode 2

	.equ		TIMx_CCMR1_OC1M_OFFSET, 4
	.equ		TIMx_CCMR1_OC2M_OFFSET, 12
	.equ		TIMx_CCMR2_OC3M_OFFSET, 4
	.equ		TIMx_CCMR2_OC4M_OFFSET, 12

	.equ		TIMx_CCER_CC1E, 1 << 0
	.equ		TIMx_CCER_CC2E, 1 << 4
	.equ		TIMx_CCER_CC3E, 1 << 8
	.equ		TIMx_CCER_CC4E, 1 << 12

	.equ		TIMx_EGR_UG, 1 << 0

