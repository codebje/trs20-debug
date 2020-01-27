ABI ?= /opt/local/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-
ZASM ?= zasm

SOURCES = main.S rom.S

OBJECTS = $(SOURCES:.S=.o)

# For qemu. Nothing actually works yet.
MACHINE = cubieboard

all: main.bin

trs20.rom: trs20.asm
	$(ZASM) -i $^ -o $@

trs20.o: trs20.rom
	$(ABI)ld -r -b binary $^ -o $@

main.bin: main.elf
	$(ABI)objcopy -S -O binary main.elf main.bin
	$(ABI)size main.elf

main.elf: main.ld $(OBJECTS) trs20.rom
	$(ABI)ld -Tmain.ld $(OBJECTS) -o main.elf

.S.o:
	$(ABI)as -mthumb -o $@ $^

clean:
	rm -f main.elf main.o

qemu:	main.elf
	# todo: need better machine option
	qemu-system-arm -cpu cortex-m4 -nographic -serial null -kernel main.elf -machine $(MACHINE) -S
