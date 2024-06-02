# Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

.include "arch.s"
.section .text.start

.equ HEXDUMP_BUFFER_SIZE, 96
.equ HEXDUMP_ADDRESS_SIZE, XLEN * 2
.equ HEXDUMP_BYTES, 16
.equ HEXDUMP_BYTES_OFFSET, HEXDUMP_ADDRESS_SIZE + 2
.equ HEXDUMP_ASCII_OFFSET, HEXDUMP_ADDRESS_SIZE + 51

.type _start, @function
.globl _start
_start:
    la sp, _stack_end
    csrr t0, mhartid
    bnez t0, _start

    # TODO: read input from user
    la a0, hello
    jal strlen

    mv a1, a0
    la a0, hello
    jal hexdump

    li a0, 0
    jal qemu_exit


# a0: address
# a1: length
.type hexdump, @function
hexdump:
    push ra
    push s0
    push s1
    push s2
    push s3
    addi sp, sp, -HEXDUMP_BUFFER_SIZE
    mv s0, a0
    mv s1, a1

__hexdump__line_prepare:
    beqz s1, __hexdump__ret
    mv a0, sp
    li a1, ' '
    li a2, HEXDUMP_BUFFER_SIZE
    jal memset

__hexdump__line_address:
    li a1, HEXDUMP_ADDRESS_SIZE
    mv a2, s0
    jal snprint_hexn

    li t0, ':'
    sb t0, HEXDUMP_ADDRESS_SIZE(a0)

    li s2, 0
    li t0, HEXDUMP_BYTES
    ble s2, t0, __hexdump__line_loop
    mv s2, t0

__hexdump__line_loop:
    beq s2, s1, __hexdump__line_print
    li t0, HEXDUMP_BYTES
    beq s2, t0, __hexdump__line_print

    slli t0, s2, 1
    add t0, t0, s2
    addi t0, t0, HEXDUMP_BYTES_OFFSET
    add a0, sp, t0

    lb s3, (s0)
    li a1, 2
    mv a2, s3
    jal snprint_hexn

    li t0, ' '
    blt s3, t0, __hexdump__ascii_dot
    li t0, '~'
    bgt s3, t0, __hexdump__ascii_dot
    j __hexdump__ascii

__hexdump__ascii_dot:
    li s3, '.'

__hexdump__ascii:
    addi a0, sp, HEXDUMP_ASCII_OFFSET
    add a0, a0, s2
    sb s3, (a0)

    addi s0, s0, 1
    addi s2, s2, 1
    j __hexdump__line_loop

__hexdump__line_print:
    li t0, '\n'
    sb t0, 1(a0)
    sb zero, 2(a0)

    mv a0, sp
    jal uart_puts

    sub s1, s1, s2
    j __hexdump__line_prepare


__hexdump__ret:
    addi sp, sp, HEXDUMP_BUFFER_SIZE
    pop s3
    pop s2
    pop s1
    pop s0
    pop ra
    ret


.section .data
hello: .string "Hello hexdump from a very long line!\n"

