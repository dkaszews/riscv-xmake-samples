# Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

.section .text


# a0: destination
# a1: source
# a2: count
# ret: destination
.type memcpy, @function
.globl memcpy
memcpy:
    mv t0, a0

__memcpy__loop:
    beqz a2, __memcpy__ret
    lb t1, (a1)
    sb t1, (a0)
    addi a0, a0, 1
    addi a1, a1, 1
    addi a2, a2, -1
    j __memcpy__loop

__memcpy__ret:
    mv a0, t0
    ret


# a0: destination
# a1: char
# a2: count
# ret: destination
.type memset, @function
.globl memset
memset:
    mv t0, a0

__memset__loop:
    beqz a2, __memset__ret
    sb a1, (a0)
    addi a0, a0, 1
    addi a2, a2, -1
    j __memset__loop

__memset__ret:
    mv a0, t0
    ret


# a0: string
# ret: length (not including null)
.type strlen, @function
    .globl strlen
strlen:
    mv t0, a0

__strlen__loop:
    lb t1, (a0)
    beqz t1, __strlen__ret
    addi a0, a0, 1
    j __strlen__loop

__strlen__ret:
    sub a0, a0, t0
    ret

