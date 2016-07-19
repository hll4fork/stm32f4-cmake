#
# toolchain file 
#

# include cmake module --> CmakeForceCompiler.cmake
include(CMakeForceCompiler)

# chip familes
set(STM32_SUPPORTED_FAMILIES F1 F4 CACHE INTERNAL "stm32 supported families")

# config toolchain's path
if(NOT TOOLCHAIN_PREFIX) # toolchain path 
    set(TOOLCHAIN_PREFIX "/usr")
    message(STATUS "No toolchain prefix specified, using default: " ${TOOLCHAIN_PREFIX})
endif()

if(NOT TARGET_TRIPLET)  # toolchain's prefix name 
    set(TARGET_TRIPLET "arm-none-eabi")
    message(STATUS "No target triplet specified, using default: " ${TARGET_TRIPLET})
endif()

# get chip's infomation
if(NOT STM32_FAMILY)
    message(STATUS "No STM32_FAMILY specified, trying to get it from STM32_CHIP")
    if(NOT STM32_CHIP)
        set(STM32_FAMILY "F1" CACHE INTERNAL "stm32 family")
        message(STATUS "Neither STM32_FAMILY nor STM32_CHIP specified, using default")
    else()
        string(REGEX REPLACE "^[sS][tT][mM]32([fF][14]).+$" "\\1" STM32_FAMILY ${STM32_CHIP})
        string(TOUPPER ${STM32_FAMILY} STM32_FAMILY)    # convert to upper
        message(STATUS "Selected STM32 family: ${STM32_FAMILY}")
    endif()
endif()

# match supported family or not 
string(TOUPPER ${STM32_FAMILY} STM32_FAMILY)
list(FIND STM32_SUPPORTED_FAMILIES ${STM32_FAMILY} FAMILY_INDEX)
if(FAMILY_INDEX EQUAL -1)
    message(FATAL_ERROR "Invalid/unsupported STM32 family: $STM32_FAMILY}")
endif()

# toolchain excutable's path and comiler's libraries files 
set(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_PREFIX}/bin)
set(TOOLCHAIN_INC_DIR ${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}/include)
set(TOOLCHAIN_LIB_DIR ${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}/lib)

# set build target 
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

CMAKE_FORCE_C_COMPILER(${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc GNU)
CMAKE_FORCE_CXX_COMPILER(${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-g++ GNU)

set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc) # try as here

# others tools
set(CMAKE_OBJCOPY ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objcopy CACHE INTERNAL "objcopy tool")
set(CMAKE_OBJDUMP ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objdump CACHE INTERNAL "objdump tool")
set(CMAKE_SIZE ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-size CACHE INTERNAL "size tool")
set(CMAKE_DEBUGER ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gdb CACHE INTERNAL "debuger")

# debug flags --> -g 
set(CMAKE_C_FLAGS_DEBUG "-Og -g" CACHE INTERNAL "c compiler flags debug")
set(CMAKE_CXX_FLAGS_DEBUG "-Og -g" CACHE INTERNAL "cxx compiler flags debug")
set(CMAKE_ASM_FLAGS_DEBUG "-g" CACHE INTERNAL "asm compiler flags debug")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "linker flags debug")

# release flags  --> Os
set(CMAKE_C_FLAGS_RELEASE "-Os -flto" CACHE INTERNAL "c compiler flags release")
set(CMAKE_CXX_FLAGS_RELEASE "-Os -flto" CACHE INTERNAL "cxx compiler flags release")
set(CMAKE_ASM_FLAGS_RELEASE "" CACHE INTERNAL "asm compiler flags release")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto" CACHE INTERNAL "linker flags release")

# root path for cross compile 
set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET} ${EXTRA_FIND_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)    # just use host system program tools
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)     # use cross compiler's libraries only
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)     # use cross compiler's header files only

# functions and macros

# create bin and hex file from elf target
function(STM32_ADD_HEX_BIN_TARGETS TARGET)
    if(EXECUTABLE_OUTPUT_PATH)
        set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}") # save bin and hex in this path 
    else()
        set(FILENAME "${TARGET}")   # save bin and hex in current path 
    endif()
    add_custom_command(TARGET ${TARGET}
                       DEPENDS ${TARGET}
                       COMMAND ${CMAKE_OBJCOPY} -Oihex ${FILENAME} ${FILENAME}.hex)
    add_custom_command(TARGET ${TARGET}
                       DEPENDS ${TARGET}
                       COMMAND ${CMAKE_OBJCOPY} -Obinary ${FILENAME} ${FILENAME}.bin)     
endfunction()

# include specified chip family
string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)
include(gcc_stm32${STM32_FAMILY_LOWER})

# set linker script
set(TARGET_LD_FLAGS "-T${CMAKE_CURRENT_SOURCE_DIR}/STM32F429ZITx_FLASH.ld")

# set HSE value
function(STM32_SET_HSE_VALUE TARGET STM32_HSE_VALUE)
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "HSE_VALUE=${STM32_HSE_VALUE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "HSE_VALUE=${STM32_HSE_VALUE}")
    endif()
    set_target_properties(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()

macro(STM32_GENERATE_LIBRARIES NAME SOURCES LIBRARIES)
    string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)
    foreach(CHIP_TYPE ${STM32_CHIP_TYPES})
        string(TOLOWER ${CHIP_TYPE} CHIP_TYPE_LOWER)
        list(APPEND ${LIBRARIES} ${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER})
        add_library(${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER} ${SOURCES})
        STM32_SET_CHIP_DEFINITIONS(${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER} ${CHIP_TYPE})
    endforeach()
endmacro()
