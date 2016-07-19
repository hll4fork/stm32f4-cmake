#
# @author   : huang li long <huanglilongwk@outlook.com>
# @time     : 2016/7/19
# @brief    : CMSIS package cmake script 
#

# common files for Cortex-M4 core
set(CMSIS_COMMON_HEADERS
    arm_common_tables.h
    arm_const_structs.h
    arm_math.h
    core_cmFunc.h
    core_cmInstr.h
    core_cmSimd.h
)

# F4 STM32Cube Firmware's path
if(NOT STM32Cube_DIR)
    set(STM32Cube_DIR "/opt/STM32Cube_FW_F4_V1.12.0")
    message(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
endif()

list(APPEND CMSIS_COMMON_HEADERS core_cm4.h)
set(CMSIS_DEVICE_HEADERS stm32f4xx.h system_stm32f4xx.h)
set(CMSIS_DEVICE_SOURCES system_stm32f4xx.c)

# set startup file
if(NOT CMSIS_STARTUP_SOURCE)
    set(CMSIS_STARTUP_SOURCE startup_stm32f429xx.s)
endif()

# get the CMSIS include files's path
find_path(CMSIS_COMMON_INCLUDE_DIR ${CMSIS_COMMON_HEADERS}
    PATH_SUFFIXES include stm32f4 cmsis
    HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Include/
    CMAKE_FIND_ROOT_PATH_BOTH
)
message("CMSIS_COMMON_INCLUDE_DIR is ${CMSIS_COMMON_INCLUDE_DIR}")

# get CMSIS device dependency include files's path
find_path(CMSIS_DEVICE_INCLUDE_DIR ${CMSIS_DEVICE_HEADERS}
    PATH_SUFFIXES include stm32f4 cmsis
    HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Device/ST/STM32F4xx/Include
    CMAKE_FIND_ROOT_PATH_BOTH
)
message("CMSIS_DEVICE_INCLUDE_DIR is ${CMSIS_DEVICE_INCLUDE_DIR}")

# collect all CMSIS header files
set(CMSIS_INCLUDE_DIRS
    ${CMSIS_DEVICE_INCLUDE_DIR}
    ${CMSIS_COMMON_INCLUDE_DIR}
)

# system_stm32f4xx.c
foreach(SRC ${CMSIS_DEVICE_SOURCES})
    set(SRC_FILE SRC_FILE-NOTFOUND)
    find_file(SRC_FILE ${SRC}
        PATH_SUFFIXES src stm32f4 cmsis
        HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/
        CMAKE_FIND_ROOT_PATH_BOTH
    )
    list(APPEND CMSIS_SOURCES ${SRC_FILE})
endforeach()

# startup file 
set(SRC_FILE SRC_FILE-NOTFOUND)
find_file(SRC_FILE ${CMSIS_STARTUP_SOURCE}
    PATH_SUFFIXES src stm32f4 cmsis
    HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/
    CMAKE_FIND_ROOT_PATH_BOTH
)
list(APPEND CMSIS_SOURCES ${SRC_FILE})


include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(CMSIS DEFAULT_MSG CMSIS_INCLUDE_DIRS CMSIS_SOURCES)
