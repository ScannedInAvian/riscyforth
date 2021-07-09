
run: boot.bin
	qemu-system-riscv32 -nographic -smp 4 -machine virt -bios none -kernel $^

boot.bin: boot.s main.c
	bin/riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -T default.lds -o $@ -nostdlib -fno-builtin $^
