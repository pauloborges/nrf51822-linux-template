# Include project specific Makefile
-include Makefile.project

export JLINK_PATH

# Device
DEVICE_FAMILY	= NRF51
CPU				= cortex-m0

ifeq ($(PROJECT_TARGET),)
    $(error PROJECT_TARGET isn't defined)
endif

# Linker script
ifeq ($(USE_SOFTDEVICE), s110)
	LINKER_SCRIPT = gcc_nrf51_s110_$(SOC_VARIANT).ld
 else
	LINKER_SCRIPT = gcc_nrf51_blank_$(SOC_VARIANT).ld
endif

# Base paths
SDK_INCLUDE_PATH	= $(NRF51_SDK_PATH)/Nordic/nrf51822/Include
SDK_SOURCE_PATH		= $(NRF51_SDK_PATH)/Nordic/nrf51822/Source
SDK_TEMPLATE_PATH	= $(NRF51_SDK_PATH)/Nordic/nrf51822/Source/templates

# Compiler tools
CC			= arm-none-eabi-gcc
OBJCOPY		= arm-none-eabi-objcopy
PROGRAMMER	= python segger.py

# Include paths
INCLUDE_PATHS	= $(SDK_INCLUDE_PATH) $(SDK_INCLUDE_PATH)/gcc $(PROJECT_INCLUDE_PATHS)
INCLUDES		= $(addprefix -I, $(INCLUDE_PATHS))

# Compiler flags
CFLAGS = -mcpu=$(CPU) -mthumb -mfloat-abi=soft -Wall -Werror -c
CFLAGS += -D$(DEVICE_FAMILY) -D$(SOC) -D$(BOARD)
CFLAGS += $(PROJECT_CFLAGS)
CFLAGS += $(INCLUDES)

ASMFLAGS = $(CFLAGS)

# Linker flags
LDFLAGS = -Xlinker -Map=$(BUILD_PATH)/$(PROJECT_TARGET).map -mcpu=$(CPU) -mthumb -mabi=aapcs
LDFLAGS += -T$(SDK_TEMPLATE_PATH)/gcc/$(LINKER_SCRIPT) -L$(SDK_TEMPLATE_PATH)/gcc
LDFLAGS += $(PROJECT_LDFLAGS)

# C sources paths & files
C_SOURCE_PATHS		= $(SDK_SOURCE_PATH) $(SDK_TEMPLATE_PATH) $(SDK_TEMPLATE_PATH)/gcc
C_SOURCE_PATHS		+= $(PROJECT_C_SOURCE_PATHS)

C_SOURCE_FILES		= system_nrf51.c $(PROJECT_C_SOURCE_FILES)

# ASM sources paths & files
ASM_SOURCE_PATHS	= $(SDK_TEMPLATE_PATH)/gcc
ASM_SOURCE_PATHS	+= $(PROJECT_ASM_SOURCE_FILES)

ASM_SOURCE_FILES	= gcc_startup_nrf51.s $(PROJECT_ASM_SOURCE_FILES)

# Build path & objects
BUILD_PATH = build

C_OBJECT_FILES		= $(addprefix $(BUILD_PATH)/, $(C_SOURCE_FILES:.c=.o))
ASM_OBJECT_FILES	= $(addprefix $(BUILD_PATH)/, $(ASM_SOURCE_FILES:.s=.o))

vpath %.c $(C_SOURCE_PATHS)
vpath %.s $(ASM_SOURCE_PATHS)

# Rules
all: $(BUILD_PATH)/$(PROJECT_TARGET).bin $(BUILD_PATH)/$(PROJECT_TARGET).hex

$(BUILD_PATH)/$(PROJECT_TARGET).hex: $(BUILD_PATH)/$(PROJECT_TARGET).out
	$(OBJCOPY) -O ihex $(BUILD_PATH)/$(PROJECT_TARGET).out $(BUILD_PATH)/$(PROJECT_TARGET).hex

$(BUILD_PATH)/$(PROJECT_TARGET).bin: $(BUILD_PATH)/$(PROJECT_TARGET).out
	$(OBJCOPY) -O binary $(BUILD_PATH)/$(PROJECT_TARGET).out $(BUILD_PATH)/$(PROJECT_TARGET).bin

$(BUILD_PATH)/$(PROJECT_TARGET).out: $(BUILD_PATH) $(C_OBJECT_FILES) $(ASM_OBJECT_FILES)
	$(CC) $(LDFLAGS) $(C_OBJECT_FILES) $(ASM_OBJECT_FILES) -o $@

# Build object files from C source files
$(BUILD_PATH)/%.o: %.c
	$(CC) $(CFLAGS) -o $@ $<

# Build object files from ASM source files
$(BUILD_PATH)/%.o: %.s
	$(CC) $(ASMFLAGS) -o $@ $<

$(BUILD_PATH):
	-mkdir $@

install upload: $(BUILD_PATH)/$(PROJECT_TARGET).bin
	$(PROGRAMMER) flash `pwd`/$(BUILD_PATH)/$(PROJECT_TARGET).bin

erase:
	$(PROGRAMMER) erase

clean:
	rm -rf build *.log

.PHONY: install upload erase clean
