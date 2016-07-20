#
# @author   : huang li long <huanglilongwk@outlook.com>
# @time     : 2016/7/19
# @brief    : CMSIS package cmake script 
#

set(HAL_COMPONENTS  adc can cec cortex crc cryp dac dcmi dma dma2d eth flash
                    flash_ramfunc fmpi2c gpio hash hcd i2c i2s irda iwdg ltdc
                    nand nor pccard pcd pwr qspi rcc rng rtc sai sd sdram
                    smartcard spdifrx spi sram tim uart usart wwdg fmc fsmc
                    sdmmc usb)

# Cortex-M core components -- required for every chip
set(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

# Components that have _ex sources
set(HAL_EX_COMPONENTS   adc cryp dac dcmi dma flash fmpi2c hash i2c i2s pcd
                        pwr rcc rtc sai tim)

# Components that have ll_ in names instead of hal_
set(HAL_LL_COMPONENTS fmc fsmc sdmmc usb)

# file prefix
set(HAL_PREFIX stm32f4xx_)

set(HAL_HEADERS
    stm32f4xx_hal.h
    stm32f4xx_hal_def.h
)

set(HAL_SRCS
    stm32f4xx_hal.c
)

# if not specified component, STM32HAL_FIND_COMPONENTS --> STM32HAL is package's name; FIND_COMPONENTS for asking find component
if(NOT STM32HAL_FIND_COMPONENTS)
    set(STM32HAL_FIND_COMPONENTS ${HAL_COMPONENTS})
    message(STATUS "No STM32HAL components selected, using all: ${STM32HAL_FIND_COMPONENTS}")
endif()

# add Cortex-M core components if not specified
foreach(cmp ${HAL_REQUIRED_COMPONENTS})
    list(FIND STM32HAL_FIND_COMPONENTS ${cmp} STM32HAL_FOUND_INDEX)
    if(${STM32HAL_FOUND_INDEX} LESS 0)
        list(APPEND STM32HAL_FIND_COMPONENTS ${cmp})
    endif()
endforeach()

# check hal components and get hal header he source files
foreach(cmp ${STM32HAL_FIND_COMPONENTS})
    list(FIND HAL_COMPONENTS ${cmp} STM32HAL_FOUND_INDEX)
    if(${STM32HAL_FOUND_INDEX} LESS 0)
        message(FATAL_ERROR "Unknown STM32HAL component: ${cmp}. Available components: ${HAL_COMPONENTS}")
    endif()
    list(FIND HAL_LL_COMPONENTS ${cmp} STM32HAL_FOUND_INDEX)
    if(${STM32HAL_FOUND_INDEX} LESS 0)
        list(APPEND HAL_HEADERS ${HAL_PREFIX}hal_${cmp}.h)
        list(APPEND HAL_SRCS ${HAL_PREFIX}hal_${cmp}.c)
    else()
        list(APPEND HAL_HEADERS ${HAL_PREFIX}ll_${cmp}.h)
        list(APPEND HAL_SRCS ${HAL_PREFIX}ll_${cmp}.c)
    endif()
    list(FIND HAL_EX_COMPONENTS ${cmp} STM32HAL_FOUND_INDEX)
    if(NOT (${STM32HAL_FOUND_INDEX} LESS 0))
        list(APPEND HAL_HEADERS ${HAL_PREFIX}hal_${cmp}_ex.h)
        list(APPEND HAL_SRCS ${HAL_PREFIX}hal_${cmp}_ex.c)
    endif()
endforeach()

# remove duplicate files
list(REMOVE_DUPLICATES HAL_HEADERS)
list(REMOVE_DUPLICATES HAL_SRCS)

# get include files's path
find_path(STM32HAL_INCLUDE_DIR ${HAL_HEADERS}
    PATH_SUFFIXES include stm32f4
    HINTS ${STM32Cube_DIR}/Drivers/STM32F4xx_HAL_Driver/Inc
    CMAKE_FIND_ROOT_PATH_BOTH
)

# get source files's absolute path
foreach(HAL_SRC ${HAL_SRCS})
    set(HAL_${HAL_SRC}_FILE HAL_SRC_FILE-NOTFOUND)
    find_file(HAL_${HAL_SRC}_FILE ${HAL_SRC}
        PATH_SUFFIXES src stm32f4
        HINTS ${STM32Cube_DIR}/Drivers/STM32F4xx_HAL_Driver/Src
        CMAKE_FIND_ROOT_PATH_BOTH
    )
    list(APPEND STM32HAL_SOURCES ${HAL_${HAL_SRC}_FILE})
endforeach()

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(STM32HAL DEFAULT_MSG STM32HAL_INCLUDE_DIR STM32HAL_SOURCES)
