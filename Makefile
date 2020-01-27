ABI ?= /opt/local/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-
ZASM ?= zasm

SOURCES = main.S

OBJECTS = $(SOURCES:.S=.o) trs20.o

# For qemu. Nothing actually works yet.
MACHINE = cubieboard

all: main.bin

trs20.rom: trs20.asm
	$(ZASM) -yu -i $^ -o $@

trs20.o: trs20.rom
	$(ABI)objcopy -I binary -O elf32-littlearm -B armv7e-m $^ \
	    --rename-section .data=.rodata,alloc,load,readonly,data,contents $@

main.bin: main.elf
	$(ABI)objcopy -S -O binary main.elf main.bin
	$(ABI)size main.elf

main.elf: main.ld $(OBJECTS)
	$(ABI)ld -Tmain.ld $(OBJECTS) -o main.elf

.S.o:
	$(ABI)as -mthumb -o $@ $^

clean:
	rm -f main.elf $(OBJECTS) trs20.rom

qemu:	main.elf
	# todo: need better machine option
	qemu-system-arm -cpu cortex-m4 -nographic -serial null -kernel main.elf -machine $(MACHINE) -S
