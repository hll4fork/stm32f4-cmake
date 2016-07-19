#
# @author   : huang li long <huanglilongwk@outlook.com>
# @time     : 2016/07/15
# @brief    : build binaries for stm32f4 
#
mkdir -p build
cd build
cmake ../stm32f4-led
make
