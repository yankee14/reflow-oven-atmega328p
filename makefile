PROJECT		:= $(notdir $(CURDIR)) # name of current directory
MCU 		:= m328p
CLOCK		:= 16E6
DEVICE_FILE := /dev/ttyACM0
FORMAT 		:= ihex

LOW_FUSE	:= 0xFF
HIGH_FUSE	:= 0xDE
EXT_FUSE	:= 0x05

SRC			:= $(PRJ).c

CC			:= avr-gcc
CFLAGS		:= 

AVRDUDE		:= avrdude
AVRDUDEFLAGS := -c arduino -p $(MCU) -P $(DEVICE_FILE)

BUILD_DIR 	:= build_$(PROJECT)

# targets
all: $(BUILD_DIR)/$(PROJECT).hex

# test avrdude connection
test:
	$(AVRDUDE) $(AVRDUDEFLAGS) -v
