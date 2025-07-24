#=============================================================================
# Makefile for STM32F411RE Bare-metal Blinky
#=============================================================================

TARGET = led_blink

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OC = arm-none-eabi-objcopy

SRCS = main.c \
	   system_stm32f4xx.c \
	   startup_stm32f411xe.s

OBJS = $(SRCS:.c=.o)
OBJS := $(OBJS:.s=.o)

# Linker Script
LDSCRIPT = STM32F411RE_FLASH.ld

# Compiler Flags
MCU_FLAGS = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS = $(MCU_FLAGS) -O2 -g -Wall -I.
CFLAGS += -fdata-sections -ffunction-sections

# Linker Flags
LDFLAGS = $(MCU_FLAGS) -Wl,-Map=$(TARGET).map,--cref -Wl,--gc-sections
LDFLAGS += -T $(LDSCRIPT)

.PHONY: all compile del_compile clean flash

all: $(TARGET).elf

$(TARGET).elf: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^
	$(OC) -O binary $@ $(TARGET).bin
	@echo "Build successful!"

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

compile:
	@echo "[" > compile_commands.json
	@$(foreach src, $(filter %.c, $(SRCS)), \
	    echo "{\"directory\": \"$(CURDIR)\", \"command\": \"$(CC) $(CFLAGS) -Iinclude -c -o $(src:.c=.o) $(src)\", \"file\": \"$(src)\"}," >> compile_commands.json;)
	@sed -i '$$s/,$$//' compile_commands.json
	@echo "]" >> compile_commands.json
	@echo "compile_commands.json has been generated."

del_compile:
	rm -rf compile_commands

clean:
	rm -f $(OBJS) $(TARGET).elf $(TARGET).bin $(TARGET).map

flash: all
	openocd -f board/st_nucleo_f4.cfg -c "program $(TARGET).elf verify reset exit"
