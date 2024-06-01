# Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

.include "arch.s"
.section .text.start

.equ BUFFER_SIZE, XLEN * 2 + 1

# .type _start, @function
.globl _start
_start:
    la sp, _stack_end
    csrr t0, mhartid
    bnez t0, _start

    addi sp, sp, -BUFFER_SIZE
    mv a0, sp
    sb zero, BUFFER_SIZE(a0)
    li a1, BUFFER_SIZE-1
    la a2, hello
    jal snprint_hexn
    jal uart_puts

    li a0, '\n'
    jal uart_putc

    addi sp, sp, BUFFER_SIZE

    li a0, 0
    jal qemu_exit


.section .data
hello: .string "Hello hexdump!\n"

