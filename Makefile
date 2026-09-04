AS := as --32
LD := ld -m elf_i386
BUILD := build
DIST := dist
IMG := $(DIST)/havenos-core.img
.PHONY: all clean
all: $(IMG)
$(BUILD):
	mkdir -p $(BUILD) $(DIST)
$(BUILD)/boot.bin: src/boot.S | $(BUILD)
	$(AS) -o $(BUILD)/boot.o src/boot.S
	$(LD) -Ttext 0 --oformat binary -o $@ $(BUILD)/boot.o
	@sz=$$(wc -c < $@); if [ "$$sz" -ne 512 ]; then echo bad boot $$sz; exit 1; fi
$(BUILD)/kernel.bin: src/kernel.S | $(BUILD)
	$(AS) -o $(BUILD)/kernel.o src/kernel.S
	$(LD) -Ttext 0x8000 --oformat binary -o $@ $(BUILD)/kernel.o
$(IMG): $(BUILD)/boot.bin $(BUILD)/kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=33 status=none
	dd if=$(BUILD)/boot.bin of=$@ conv=notrunc status=none
	dd if=$(BUILD)/kernel.bin of=$@ bs=512 seek=1 conv=notrunc status=none
	ls -l $@
clean:
	rm -rf $(BUILD) $(DIST)
