#
# @author   : huang li long <huanglilongwk@outlook.com>
# @time     : 2016/07/15
# @brief    : flashing binaries to stm32f4 
# you should install st-flash in your computer
# https://github.com/texane/stlink
#
st-flash write build/stm32f4-led.bin 0x8000000


#
# Debug method 1 --> openocd (windows and linux)
# Debug scripts -- openocd
# 
#openocd -s /usr/share/openocd/scripts -f board/stm32f429discovery.cfg

#
# New terminal (openocd)
#
# commands:
#   $ arm-none-eabi-gdb build/stm32f4-led
#   $ tar ext:3333
#   $ continue
#


#
# Debug method 2 --> st-util (linux)
# if you have st-util install in your system, you can use it for debuging
# more infomation --> https://github.com/texane/stlink
#
# commands:
#   $ st-util

#
# New terminal (st-util)
#
# commands:
#   $ arm-none-eabi-gdb build/stm32f4-led (elf file)
#   $ tar ext:4242
#   $ continue

