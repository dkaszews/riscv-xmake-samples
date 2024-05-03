# Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

.include "arch.s"
.section .text.start


.equ BUFFER_SIZE, 0x20
.equ BUFFER_SIZE_LENGTH, 0x2


# .type _start, @function
.globl _start
_start:
    la sp, _stack_end
    csrr t0, hartid
    bnez t0, _start

    jal echo_hello
    jal qemu_exit


.section .text
.type echo_hello, @function
.globl echo_hello
echo_hello:
    push ra
    addi sp, sp, -BUFFER_SIZE

    mv s0, sp
    addi s1, s0, BUFFER_SIZE-1

    la a0, prompt
    jal uart_puts

_echo_hello__loop:
    jal uart_getc
    bltz a0, _echo_hello__loop

    jal uart_putc
    li t0, '\n'
    beq a0, t0, _echo_hello__end

    sb a0, 0(s0)
    addi s0, s0, 1

    beq s0, s1, _echo_hello__long
    j _echo_hello__loop

_echo_hello__long:
    li a0, '\n'
    jal uart_putc
    la a0, too_long
    jal uart_puts
    la a0, 1
    j _echo_hello__ret

_echo_hello__end:
    sb zero, 0(s0)

    la a0, hello
    jal uart_puts
    mv a0, sp
    jal uart_puts
    la a0, hello2
    jal uart_puts

    mv a0, sp
    li a1, BUFFER_SIZE_LENGTH
    sub a2, s0, sp
    jal snprint_hexn
    sb zero, BUFFER_SIZE_LENGTH(sp)
    mv a0, sp
    jal uart_puts

    la a0, hello3
    jal uart_puts

    li a0, 0

_echo_hello__ret:
    addi sp, sp, BUFFER_SIZE
    pop ra
    ret


.section .data
prompt: .string "Input your name: "
hello: .string "Hello, "
hello2: .string "! Your name is 0x"
hello3: .string " bytes long.\n"
too_long: .string "Your name is too long!\n"

