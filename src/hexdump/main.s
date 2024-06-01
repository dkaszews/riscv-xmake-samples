# Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

.include "arch.s"
.section .text.start

.equ HELLO_LEN, 15
.equ BUFFER_SIZE, 96
.equ ADDRESS_HEX_LEN, XLEN*2
.equ TEMPLATE_LEN, 72
.equ HEXDUMP_LINE_BYTES, 16

.type _start, @function
.globl _start
_start:
    la sp, _stack_end
    csrr t0, mhartid
    bnez t0, _start

    la a0, hello
    la a1, HELLO_LEN
    jal hexdump

    li a0, 0
    jal qemu_exit


# a0: address
# a1: length
.type hexdump, @function
hexdump:
    push ra

__hexdump__loop:
    beqz a1, __hexdump__ret
    # TODO: inline
    jal hexdump_line
    j __hexdump__loop

__hexdump__ret:
    pop ra
    ret


# a0: address
# a1: length, guaranteed non zero
# ret0: next_address
# ret1: remaining_length
.type hexdump, @function
hexdump_line:
    push ra
    push s0
    push s1
    push s2
    addi sp, sp, -BUFFER_SIZE

    mv s0, a0
    mv s1, a1

__hexdump_line__address:
    mv a2, a0
    mv a0, sp
    li a1, ADDRESS_HEX_LEN
    jal snprint_hexn

    addi a0, a0, ADDRESS_HEX_LEN
    la a1, template
    li a2, TEMPLATE_LEN
    jal memcpy

__hexdump_line__byte:
    addi a0, a0, 2
    li s2, 0
    li t0, 16
    ble s2, t0, __hexdump_line__loop
    mv s2, t0

__hexdump_line__loop:
    beq s2, s1, __hexdump_line__print
    li t0, HEXDUMP_LINE_BYTES
    beq s2, t0, __hexdump_line__print
    li a1, 2
    lb a2, (s0)
    jal snprint_hexn

    addi a0, a0, 3
    addi s0, s0, 1
    addi s2, s2, 1
    li t0, HEXDUMP_LINE_BYTES / 2
    bne s2, t0, __hexdump_line__loop
    addi a0, a0, 1
    j __hexdump_line__loop

__hexdump_line__print:
    mv a0, sp
    jal uart_puts


__hexdump_line__ret:
    sub a0, s0, s2
    sub a1, s1, s2

    addi sp, sp, BUFFER_SIZE
    pop s2
    pop s1
    pop s0
    pop ra
    ret


.section .data
hello: .string "Hello hexdump!\n"
template: .string "                                                    |                |\n"

