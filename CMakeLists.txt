cmake_minimum_required(VERSION 3.13.4)

# project and output binary name
get_filename_component(ProjectId ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" ProjectId ${ProjectId})
project(${ProjectId})

set(PRODUCT_NAME ${ProjectId})
set(F_CPU 16E6)
set(MCU atmega328p)
set(BAUD 115200)
set(PROGRAMMER arduino)
set(IFACE /dev/ttyACM0)

set(LOW_FUSE 0xFF)
set(HIGH_FUSE 0xD6)
set(EXT_FUSE 0x05)

# use avr-gcc
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_ASM_COMPILER avr-gcc)
set(CMAKE_C_COMPILER avr-gcc)
set(CMAKE_CXX_COMPILER avr-g++)

add_definitions(
    -DF_CPU=${F_CPU}
    -DBAUD=${BAUD}
)

set(CMAKE_EXE_LINKER_FLAGS -mmcu=${MCU})

add_compile_options(
    -mmcu=${MCU}
    -std=gnu11
    -O1
    -Wall
    -Wextra
    #-Wno-main
    -Wpedantic
    -Wstrict-prototypes
    -Wundef
    -Werror
    -Wfatal-errors
    -Wl,--relax,--gc-sections
    -g
    -gdwarf-2
)

# load all c files
file(GLOB SRC_FILES "*.c")

# Create one target
add_executable(${PRODUCT_NAME} ${SRC_FILES})

# rename output to .elf
set_target_properties(${PRODUCT_NAME} PROPERTIES OUTPUT_NAME ${PRODUCT_NAME}.elf)

# strip binary for upload
add_custom_target(strip ALL avr-strip ${PRODUCT_NAME}.elf DEPENDS ${PRODUCT_NAME})

# transform binary into hex, ignore EEPROM
add_custom_target(hex ALL avr-objcopy -R .eeprom -O ihex ${PRODUCT_NAME}.elf ${PRODUCT_NAME}.hex DEPENDS strip)

# transform binary into hex, this is eeprom part (empty if not using static eeprom variables)
add_custom_target(eeprom avr-objcopy -j .eeprom, --set-section-flags=.eeprom="alloc,load" --change-section-lma .eeprom=0 -hex ${PRODUCT_NAME}.elf ${PRODUCT_NAME}.eep DEPENDS strip)

# upload with avrdude
add_custom_target(upload avrdude -v -c ${PROGRAMMER} -p ${MCU} -P ${IFACE} -U flash:w:${PRODUCT_NAME}.hex DEPENDS hex)

# upload eeprom
add_custom_target(upload_eeprom avrdude -v -c ${PROGRAMMER} -p ${MCU} -P ${IFACE} -U eeprom:w:${PRODUCT_NAME}.eep DEPENDS eeprom)

# clean extra files
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${PRODUCT_NAME}.hex;${PRODUCT_NAME}.eeprom;${PRODUCT_NAME}.list")
