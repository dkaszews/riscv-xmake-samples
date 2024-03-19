# Provided as part of riscv-xmake-samples under MIT license, (c) 2024 Dominik Kaszewski

# XLEN-sized stores for basic generic code
.ifdef ARCH_RV32G

.equ XLEN, 4
.macro sx, reg, mem
sw \reg, \mem
.endm
.macro lx, reg, mem
lw \reg, \mem
.endm

.endif
.ifdef ARCH_RV64G

.equ XLEN, 8
.macro sx, reg, mem
sd \reg, \mem
.endm
.macro lx, reg, mem
ld \reg, \mem
.endm

.endif
.ifndef XLEN

.error "Unknown arch"

.endif

.macro push, reg
addi sp, sp, -XLEN
sx \reg, (sp)
.endm

.macro pop, reg
lx \reg, (sp)
addi sp, sp, XLEN
.endm

