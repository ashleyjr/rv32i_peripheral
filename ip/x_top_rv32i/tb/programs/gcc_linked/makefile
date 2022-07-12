
SOURCES       := $(shell find . -name '*.c')
OBJECTS       := $(SOURCES:%.c=%.o)
TESTDATA      := $(SOURCES:%.c=%.elf)
HEXDATA       := $(SOURCES:%.c=%.hex)
MEMDATA       := $(SOURCES:%.c=%.mem)
DISDATA       := $(SOURCES:%.c=%.dis)


CFLAGS=-mabi=ilp32 -march=rv32i -O0
LDFLAGS=-T riscv.ld -m elf32lriscv 
PREFIX=riscv32-unknown-elf
OC=$(PREFIX)-objcopy
OD=$(PREFIX)-objdump
CC=$(PREFIX)-gcc
LD=$(PREFIX)-ld

CFLAGS=-mabi=ilp32 -march=rv32i -nostartfiles -nostdlib -lgcc
LDFLAGS=-T riscv.ld 

all: $(TESTDATA) $(MEMDATA) $(HEXDATA) $(DISDATA)

%.elf: %.c
		@echo "Building $< -> $@"
		@$(CC) -c $(CFLAGS) -o $(@:%.elf=%.o) $<
		@$(CC) $(LDFLAGS) $(@:%.elf=%.o) -o $@

%.hex: %.elf
		@echo "Building $< -> $@"
		@$(OC) -O ihex $(@:%.hex=%.elf) $@ --only-section .text\*

%.mem: %.elf  ## Readmemh 32bit memory file
		@echo "Building $< -> $@"
		@$(OC) -O binary $(@:%.mem=%.elf) $(@:%.mem=%.bin) --only-section .text\*
		@hexdump -ve '1/4 "%08x\n"' $(@:%.mem=%.bin) > $@

%.dis: %.elf
		@echo "Dissasemble $< -> $@"
		@$(OD) -d $< > $@

clean:
		@echo "Cleaning build files"
		@rm -f $(OBJECTS) *.elf *.hex *.mem *.bin *.dis

