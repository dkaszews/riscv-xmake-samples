# Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

.section .text


# Prints exactly `length` least significant hex digits of `value` to `buffer`.
# Number is zero-padded if needed, but any digits above `length` are discarded.
# The `buffer` is NOT null-terminated.
#
# a0: buffer
# a1: length
# a2: value
.type snprint_hexn, @function
.globl snprint_hexn
snprint_hexn:
    la t0, hex_digits
    add a0, a0, a1

_snprint_hexn__loop:
    addi a0, a0, -1
    beqz a1, _snprint_hexn__ret
    andi t1, a2, 0xf
    srli a2, a2, 0x4
    add t1, t1, t0
    lb t1, 0(t1)
    sb t1, 0(a0)
    addi a1, a1, -1
    j _snprint_hexn__loop

_snprint_hexn__ret:
    ret


.section .data
hex_digits: .string "0123456789abcdef"

