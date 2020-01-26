MACHINE=cubieboard
ABI?=/opt/local/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-

all: main.bin

main.bin: main.elf
	$(ABI)objcopy -S -O binary main.elf main.bin
	$(ABI)size main.elf

main.elf: main.o
	$(ABI)ld -Ttext 0x8000000 main.o -o main.elf

.S.o:
	$(ABI)as -mthumb -o $@ $^

clean:
	rm -f main.elf main.o

qemu:	main.elf
	# todo: need better machine option
	qemu-system-arm -cpu cortex-m4 -nographic -serial null -kernel main.elf -machine $(MACHINE) -S
