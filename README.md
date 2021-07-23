# riscyforth

FORTH implemented in RISC-V assembly, cause why not

## Install Toolchain

Download and install [this prebuilt RISC-V toolchain](https://github.com/stnolting/riscv-gcc-prebuilt/releases/tag/rv32i-2.0.0).

## Install QEMU

    apt install qemu-system-misc

## Build and Run

    make

## How to Quit qemu

`Ctrl+A x`

## References

- https://wiki.osdev.org/HiFive-1_Bare_Bones
- https://matrix89.github.io/writes/writes/experiments-in-riscv/
- [default.lds](https://github.com/michaeljclark/riscv-probe/blob/master/env/qemu-sifive_u/default.lds)
- [RISC-V spec v2.2](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf) (2017-05)
