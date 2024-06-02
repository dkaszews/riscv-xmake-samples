# RISC-V bare metal assembly with xmake
RISC-V example programs, written in bare metal (no BIOS) machine mode assembly for use with the QEMU virt device.
Provided as a reference for getting started with RISC-V assembly.

## Features
* UART input and output, works with UTF-8 (backspace and ANSI escapes passthrough)
* Supports both 32 and 64bit via helper macros and conditional compilation, no C preprocessor required
* Clean exit from QEMU with return code indicating success or failure
* Instructions for debugging with GDB

## Projects
* [`hello`](src/hello/main.s) - Hello world program, echoing user input and its size, with buffer overflow check
* [`hexdump`](src/hexdump/main.s) - Prints buffer with user provided content in format equivalent to `xxd -g1`

## Usage
1. Install [`xmake`](https://xrepo.xmake.io/#/getting_started?id=get-started), `gcc-riscv64-unknown-elf` toolchain
1. `xmake build $PROJECT`
1. `xmake run $PROJECT`
1. To debug, run `xmake run gdb $PROJECT` in one terminal and `xmake run attach $PROJECT` in another
    * Optionally, install `gdb-multiarch` to get register ABI names instead of canonical ones
1. Switch between configurations with `xmake config --arch=rv32g` and `--arch=rv64g`

## References
1. [noteed/riscv-hello-asm](https://github.com/noteed/riscv-hello-asm.git) - toolchain, harts
1. [Benjamin-Davies/spark-minimal-uart](https://github.com/Benjamin-Davies/spark-minimal-uart.git) - UART I/O with status registers
1. [rust-embedded/qemu-exit](https://github.com/rust-embedded/qemu-exit) - clean exit from QEMU
1. [QEMU GDB usage](https://qemu-project.gitlab.io/qemu/system/gdb.html) - attaching debugger

