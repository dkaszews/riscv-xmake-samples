/* Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

STACK_SIZE = 32K;

SECTIONS
{
    /* Put .text.start first, to guarantee _start is at 0x8000'0000 */
    . = 0x80000000;
    .text : {  *(.text.start); *(.text); *(.text.*) }
    .stack : {
        . = ALIGN(1K);
        _stack_begin = .;
        . += STACK_SIZE;
        _stack_end = .;
    }
    .data : { *(.data); *(.data.*) }
}

