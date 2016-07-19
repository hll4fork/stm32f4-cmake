#
# toolchain file 
#

# include cmake module --> CmakeForceCompiler.cmake
include(CMakeForceCompiler)

# config toolchain's path
if(NOT TOOLCHAIN_PREFIX) # toolchain path 
    set(TOOLCHAIN_PREFIX "/usr")
    message(STATUS "No toolchain prefix specified, using default: " ${TOOLCHAIN_PREFIX})
endif()

if(NOT TARGET_TRIPLET)  # toolchain's prefix name 
    set(TARGET_TRIPLET "arm-none-eabi")
    message(STATUS "No target triplet specified, using default: " ${TARGET_TRIPLET})
endif()

# toolchain excutable's path and comiler's libraries files 
set(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_PREFIX}/bin)
set(TOOLCHAIN_INC_DIR ${TOOLCHAIN_PREFIX}/lib/${TARGET_TRIPLET}/include)
set(TOOLCHAIN_LIB_DIR ${TOOLCHAIN_PREFIX}/lib/${TARGET_TRIPLET}/lib)

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

# set f4 compiler flags
set(CMAKE_C_FLAGS "--specs=rdimon.specs -mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "c compiler flags")
set(CMAKE_CXX_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "cxx compiler flags")
set(CMAKE_ASM_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")

set(CMAKE_EXE_LINKER_FLAGS "-Wl,-Map=${CMAKE_PROJECT_NAME}.map -Wl,--gc-sections -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "executable linker flags")
set(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "module linker flags")
set(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "shared linker flags")

# set up stm32cub's definitions 
add_definitions(-DSTM32F429xx)

# set linker script
function(STM32_LINKER_SCRIPT TARGET)
    get_target_property(TARGET_LD_FLAGS ${TARGET} LINK_FLAGS)
    set(TARGET_LD_FLAGS "-T${CMAKE_CURRENT_SOURCE_DIR}/STM32F429ZITx_FLASH.ld")
    set_target_properties(${TARGET} PROPERTIES LINK_FLAGS ${TARGET_LD_FLAGS})
endfunction()

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