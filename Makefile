ABI ?= /opt/local/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-
ZASM ?= zasm
RUSTMTEST ?= /opt/local/bin/rustmtest

BUILD = ./build
DEPDIR = ./.dep

SOURCES = start.s main.s vectors.s
OBJECTS = $(SOURCES:%.s=$(BUILD)/%.o) $(BUILD)/trs20.o
DEPENDS = $(SOURCES:%.s=$(DEPDIR)/%.d)

all: $(BUILD)/main.bin

$(BUILD)/trs20.rom: trs20.asm
	@mkdir -p $(dir $@)
	$(ZASM) -yu -l $(dir $@) -i $^ -o $@

$(BUILD)/trs20.o: $(BUILD)/trs20.rom
	@mkdir -p $(dir $@)
	$(ABI)objcopy -I binary -O elf32-littlearm -B armv7e-m $^ \
	    --rename-section .data=.rodata,alloc,load,readonly,data,contents $@

$(BUILD)/main.bin: $(BUILD)/main.elf
	@mkdir -p $(dir $@)
	$(ABI)objcopy -S -O binary $< $@
	$(ABI)size $(BUILD)/main.elf

$(BUILD)/main.elf: main.ld $(OBJECTS)
	@mkdir -p $(dir $@)
	$(ABI)ld -Tmain.ld $(OBJECTS) -o $@

$(BUILD)/%.o : %.s $(DEPDIR)/%.d | $(DEPDIR)
	@mkdir -p $(dir $@)
	$(ABI)as -mthumb -MD $(DEPDIR)/$*.d -o $@ $<
	@touch $@

clean:
	rm -f $(BUILD)/main.elf $(BUILD)/main.bin $(OBJECTS) $(BUILD)/trs20.rom $(BUILD)/trs20.lst

flash:	$(BUILD)/main.bin
	dfu-util -a 0 -s 0x08000000:leave -D $(BUILD)/main.bin

.PHONY: test
test:	| $(BUILD)/main.elf
	@$(RUSTMTEST) $(BUILD)/main.elf test/*.test

$(DEPDIR):
	@mkdir -p $(DEPDIR)
$(DEPENDS): ;
include $(wildcard $(DEPENDS))
