# Build & Flash MCUBoot

Generate a signing key (or use the old one): `imgtool keygen -k mcuboot/signing-key-ed25519.pem -t ed25519`

`west build -b particle_xenon -p always -d build-mcuboot mcuboot/boot/zephyr -- '-DDTC_OVERLAY_FILE=../../config/boards/shields/lab68/lab68_mcuboot.overlay' '-DOVERLAY_CONFIG=../../../config/boards/shields/lab68/lab68_mcuboot_defconfig'`

`openocd -f interface/cmsis-dap.cfg -f nrf52-particle.cfg -c "init" -c "reset init" -c "halt" -c "program $(pwd)/build-mcuboot/zephyr/zephyr.hex 0x0 verify reset" -c "exit"`

Now hold the button and insert USB

# Build & Flash ZMK

`west build -s zmk/app -b particle_xenon -p always -d build-zmk -- -DSHIELD=lab68 -DZMK_CONFIG="$(pwd)/config"`

`west sign -t imgtool --no-hex --bin -d build-zmk -B zmk.signed.bin -- --key mcuboot/signing-key-ed25519.pem`

Get MCUMGR: `go get github.com/apache/mynewt-mcumgr-cli/mcumgr`

Get imgtool: `pip3 install --user -U imgtool`

Flash ZMK (hold MODE button and insert device in USB): `mcumgr --conntype=serial --connstring='dev=/dev/ttyACM0,baud=115200' image upload -e zmk.signed.bin`
