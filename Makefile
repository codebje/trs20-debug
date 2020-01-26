MACHINE=cubieboard

all: main.bin

main.bin: main.elf
	arm-none-eabi-objcopy -S -O binary main.elf main.bin
	arm-none-eabi-size main.elf

main.elf: main.o
	/opt/local/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-ld -Ttext 0x8000000 main.o -o main.elf

.S.o:
	/opt/local/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-as -mthumb -o $@ $^

clean:
	rm -f main.elf main.o

qemu:	main.elf
	# todo: need better machine option
	qemu-system-arm -cpu cortex-m4 -nographic -serial null -kernel main.elf -machine $(MACHINE) -S
