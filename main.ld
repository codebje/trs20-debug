/*
 * Linker script for TRS-20 debug board.
 *
 * The STM32F4 has Flash memory mapped at 0x08000000, and SRAM mapped at 0x20000000.
 *
 * In Flash boot mode, the Flash will be aliased to 0x00000000.
 *
 * The first contents of Flash must be the vector table.
 */

ENTRY(_start)

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 256K
    SRAM (xrw)  : ORIGIN = 0x20000000, LENGTH = 64K
}

/* The ROM base address is 32k below the end of Flash. */
_rom_base = 0x08038000;

SECTIONS {

    /* text section */
    .text : {
        KEEP(*(.vectors))       /* required to prevent ld eliminating this section */
        . = ALIGN(4);
        *(.text)
        *(.text*)
    } >FLASH =0xFF

    /* fixed data and TRS-20 ROM */
    .rodata : {
        . = ALIGN(32768);
        KEEP(*(.rodata))
    } >FLASH =0xFF

    /* ROM fixed locations
     * 0x803c000   0b1000000000111100000000000000
     * 16383                     0b11111111111111
     * 0x8038000   0b1000000000111000000000000000
     * 32767                    0b111111111111111
    */

}
