# Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

.include "arch.s"
.section .text


.equ UART_BASE, 0x10000000
.equ UART_RX, 0x0
.equ UART_TX, 0x0
.equ UART_STATUS, 0x5
.equ UART_STATUS_RX, (1<<0)
.equ UART_STATUS_TX, (1<<5)


# a0: char
.type uart_putc, @function
.globl uart_putc
uart_putc:
    li t0, UART_BASE

_uart_putc__loop:
    lb t1, UART_STATUS(t0)
    andi t1, t1, UART_STATUS_TX
    beqz t1, _uart_puts__loop

    sb a0, UART_TX(t0)
    ret


# a0: null-terminated string
.type uart_puts, @function
.globl uart_puts
uart_puts:
    push ra
    push s0
    mv s0, a0

_uart_puts__loop:
    lb a0, 0(s0)
    beqz a0, _uart_puts__ret
    jal uart_putc
    addi s0, s0, 1
    j _uart_puts__loop

_uart_puts__ret:
    pop s0
    pop ra
    ret


# ret: char or -1 if not available
.type uart_getc, @function
.globl uart_getc
uart_getc:
    li t0, UART_BASE
    lb a0, UART_STATUS(t0)
    andi a0, a0, UART_STATUS_RX
    beqz a0, _uart_getc__none

    lbu a0, UART_RX(t0)
    li t0, '\r'
    beq a0, t0, _uart_getc__cr
    ret

_uart_getc__cr:
    li a0, '\n'
    ret

_uart_getc__none:
    li a0, -1
    ret

