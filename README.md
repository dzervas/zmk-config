# Build & Flash MCUBoot

`west build -b particle_xenon -p always mcuboot/boot/zephyr -- '-DDTC_OVERLAY_FILE=../../config/boards/shields/lab68/lab68_mcuboot.overlay' '-DOVERLAY_CONFIG=../../../config/boards/shields/lab68/lab68_mcuboot_defconfig'`
`openocd -f interface/cmsis-dap.cfg -f nrf52-particle.cfg -c "init" -c "reset init" -c "halt" -c "program $(pwd)/build/zephyr/zephyr.hex 0x0 verify reset" -c "exit"`

Now hold the button and insert USB

# Build & Flash ZMK

`west build -s zmk/app -b particle_xenon -p -- -DSHIELD=lab68 -DZMK_CONFIG="$(pwd)/config"`
Get MCUMGR: `go get github.com/apache/mynewt-mcumgr-cli/mcumgr`
Get imgtool: `pip3 install --user -U imgtool`
Flash ZMK (hold MODE button and insert device in USB): `mcumgr --conntype=serial --connstring='dev=/dev/ttyACM0,baud=115200' image upload -e Lab68.signed.bin`
