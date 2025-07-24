#=============================================================================
# Makefile for STM32F411RE Bare-metal Blinky
#=============================================================================

TARGET = led_blink

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OC = arm-none-eabo-objcopy

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

.PHONTY: all clean flash

all: $(Target).elf

$(TARGET).elf: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^
	$(OC) -O binary $@ $(TARGET).bin
	@echo "Build successful!"

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET).elf $(TARGET).bin $(TARGET).map

flash: all
	openocd -f board/st_nucleo_f4.cfg -c "program $(TARGET).elf verify reset exit"
