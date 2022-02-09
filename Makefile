BUILD_DIR_ZMK := build-zmk
BUILD_DIR_MCUBOOT := build-mcuboot
BINARY_PATH_ZMK := zephyr/zmk.bin
BINARY_PATH_MCUBOOT := zephyr/zephyr.hex
FLASH_DEVICE := /dev/ttyACM0
SIGNING_KEY := mcuboot/signing-key-ed25519.pem

.PHONY: ci_setup clean flash flash_clean flash_mcuboot flash_mcuboot_clean init serial

all: $(BUILD_DIR_MCUBOOT)/$(BINARY_PATH_MCUBOOT) zmk.signed.bin

$(BUILD_DIR_ZMK)/$(BINARY_PATH_ZMK):
	west build -s zmk/app -b particle_xenon -d build-zmk -- -DSHIELD=lab68 -DZMK_CONFIG="$(shell pwd)/config"

$(BUILD_DIR_MCUBOOT)/$(BINARY_PATH_MCUBOOT):
	west build -b particle_xenon -d build-mcuboot mcuboot/boot/zephyr -- '-DDTC_OVERLAY_FILE=../../config/boards/shields/lab68/lab68_mcuboot.overlay' '-DOVERLAY_CONFIG=../../../config/boards/shields/lab68/lab68_mcuboot_defconfig'

zmk.signed.bin: $(BUILD_DIR_ZMK)/$(BINARY_PATH_ZMK)
	west sign -t imgtool --no-hex --bin -d build-zmk -B zmk.signed.bin -- --key $(SIGNING_KEY)

ci_setup:
	@echo "[+] Update package cache"
	apt-get update
	@echo "[+] Install pip3"
	apt-get install -y python3-pip
	@echo "[+] Install mcuboot requirements"
	pip3 install -r mcuboot/scripts/requirements.txt
	@echo "[+] Install imgtool"
	pip3 install imgtool

clean:
	rm -rf build-zmk build-mcuboot zmk.signed.bin

flash: zmk.signed.bin
	mcumgr --conntype=serial --connstring='dev=$(FLASH_DEVICE),baud=115200' image upload -e $<

flash_clean: clean flash

flash_mcuboot: $(BUILD_DIR_MCUBOOT)/$(BINARY_PATH_MCUBOOT)
	openocd -f interface/cmsis-dap.cfg -f nrf52-particle.cfg -c "init" -c "reset init" -c "halt" -c "program $(shell pwd)/$< 0x0 verify reset" -c "exit"

flash_mcuboot_clean: clean flash_mcuboot

init:
	west init -l config
	west update
	west zephyr-export

serial:
	python -m serial --raw $(FLASH_DEVICE) 115200

update:
	west update
