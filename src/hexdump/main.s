# Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

.include "arch.s"
.section .text.start

.equ HELLO_LEN, 15
.equ BUFFER_SIZE, 96
.equ ADDRESS_HEX_LEN, XLEN * 2
.equ TEMPLATE_LEN, 72
.equ HEXDUMP_LINE_BYTES, 16
.equ HEXDUMP_BYTES_OFFSET, ADDRESS_HEX_LEN + 2
.equ HEXDUMP_ASCII_OFFSET, ADDRESS_HEX_LEN + 53

.type _start, @function
.globl _start
_start:
    la sp, _stack_end
    csrr t0, mhartid
    bnez t0, _start

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
    push s3
    addi sp, sp, -BUFFER_SIZE
    mv s0, a0
    mv s1, a1

__hexdump_line__clear:
    mv a0, sp
    li a1, ' '
    li a2, TEMPLATE_LEN
    jal memset

__hexdump_line__address:
    li a1, ADDRESS_HEX_LEN
    mv a2, s0
    jal snprint_hexn

    li s2, 0
    li t0, 16
    ble s2, t0, __hexdump_line__loop
    mv s2, t0

__hexdump_line__loop:
    beq s2, s1, __hexdump_line__print
    li t0, HEXDUMP_LINE_BYTES
    beq s2, t0, __hexdump_line__print

    slli t0, s2, 1
    add t0, t0, s2
    addi t0, t0, HEXDUMP_BYTES_OFFSET
    add a0, sp, t0
    li t0, HEXDUMP_LINE_BYTES / 2
    blt s2, t0, __hexdump_line__loop_no_extra_space
    addi a0, a0, 1

__hexdump_line__loop_no_extra_space:
    lb s3, (s0)
    li a1, 2
    mv a2, s3
    jal snprint_hexn

    li t0, ' '
    blt s3, t0, __hexdump_line__dot
    li t0, '~'
    bgt s3, t0, __hexdump_line__dot
    j __hexdump_line__ascii

__hexdump_line__dot:
    li s3, '.'

__hexdump_line__ascii:
    addi a0, sp, HEXDUMP_ASCII_OFFSET
    add a0, a0, s2
    sb s3, (a0)

    addi s0, s0, 1
    addi s2, s2, 1
    j __hexdump_line__loop

__hexdump_line__print:
    li t0, '\n'
    sb t0, 2(a0)
    li t0, '|'
    sb t0, 1(a0)
    sb zero, 3(a0)
    addi a0, sp, HEXDUMP_ASCII_OFFSET
    sb t0, -1(a0)

    mv a0, sp
    jal uart_puts


__hexdump_line__ret:
    mv a0, s0
    sub a1, s1, s2

    addi sp, sp, BUFFER_SIZE
    pop s3
    pop s2
    pop s1
    pop s0
    pop ra
    ret


.section .data
hello: .string "Hello hexdump!\n"

