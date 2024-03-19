# RISC-V bare metal assembly with xmake
Small "Hello World" echo program, written in bare metal (no BIOS) RISC-V machine mode assembly for use with the QEMU virt device.
Provided as a reference for getting started with RISC-V assembly.

## Features
* UART input and output, works with UTF-8 (backspace and ANSI escapes passthrough)
* Supports both 32 and 64bit via helper macros and conditional compilation, no C preprocessor required
* Clean exit from QEMU with return code indicating success or failure (on checked overflow)
* Instructions for debugging with GDB

## Usage
1. Install [`xmake`](https://xrepo.xmake.io/#/getting_started?id=get-started), `gcc-riscv64-unknown-elf` toolchain
1. `xmake`
1. `xmake run qemu`
1. To debug, run `xmake run qemu-gdb` in one terminal and `xmake run gdb-attach` in another
    * Optionally, install `gdb-multiarch` to get register ABI names instead of canonical ones
1. Switch between configurations with `xmake config --arch=rv32g` and `--arch=rv64g`

## References
1. [noteed/riscv-hello-asm](https://github.com/noteed/riscv-hello-asm.git) - toolchain, harts
1. [Benjamin-Davies/spark-minimal-uart](https://github.com/Benjamin-Davies/spark-minimal-uart.git) - UART I/O with status registers
1. [rust-embedded/qemu-exit](https://github.com/rust-embedded/qemu-exit) - clean exit from QEMU
1. [QEMU GDB usage](https://qemu-project.gitlab.io/qemu/system/gdb.html) - attaching debugger

