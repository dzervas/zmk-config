BUILD_DIR_ZMK := build-zmk
BUILD_DIR_MCUBOOT := build-mcuboot
BINARY_PATH_ZMK := zephyr/zmk.bin
BINARY_PATH_MCUBOOT := zephyr/zephyr.hex
TARGET_SHIELD := lab68
FLASH_DEVICE := /dev/serial/by-id/usb-ZEPHYR_Lab68_MCUBoot_0194B9F6D412E852-if00
ZMK_DEVICE := /dev/serial/by-id/usb-ZMK_Project_Lab68_0194B9F6D412E852-if00
SIGNING_KEY := mcuboot/signing-key-ed25519.pem

.PHONY: ci_setup clean clean_mcuboot clean_zmk flash flash_clean flash_mcuboot flash_mcuboot_clean init serial

all: $(BUILD_DIR_MCUBOOT)/$(BINARY_PATH_MCUBOOT) zmk.signed.$(TARGET_SHIELD).bin

$(BUILD_DIR_ZMK)/$(BINARY_PATH_ZMK):
	west build -s zmk/app -b particle_xenon -d build-zmk -- -DSHIELD=$(TARGET_SHIELD) -DZMK_CONFIG="$(shell pwd)/config"

$(BUILD_DIR_MCUBOOT)/$(BINARY_PATH_MCUBOOT):
	west build -b particle_xenon -d build-mcuboot mcuboot/boot/zephyr -- "-DDTC_OVERLAY_FILE=../../config/boards/shields/$(TARGET_SHIELD)/$(TARGET_SHIELD)_mcuboot.overlay" '-DOVERLAY_CONFIG=../../../config/boards/shields/$(TARGET_SHIELD)/$(TARGET_SHIELD)_mcuboot_defconfig'

zmk.signed.$(TARGET_SHIELD).bin: $(BUILD_DIR_ZMK)/$(BINARY_PATH_ZMK)
	west sign -t imgtool --no-hex --bin -d build-zmk -B $< -- --key $(SIGNING_KEY)

ci_setup:
	@echo "[+] Update package cache"
	apt-get update
	@echo "[+] Install pip3"
	apt-get install -y python3-pip
	@echo "[+] Install mcuboot requirements"
	pip3 install -r mcuboot/scripts/requirements.txt
	@echo "[+] Install imgtool"
	pip3 install imgtool

clean: clean_mcuboot clean_zmk

clean_mcuboot:
	rm -rf build-mcuboot

clean_zmk:
	rm -rf build-zmk zmk.signed.bin

flash: zmk.signed.bin
	while ! stat $(FLASH_DEVICE) 2>&1 >/dev/null; do echo "Waiting for device $(FLASH_DEVICE)"; sleep 5; done
	mcumgr --conntype=serial --connstring='dev=$(FLASH_DEVICE),baud=115200' image upload -e $<
	mcumgr --conntype=serial --connstring='dev=$(FLASH_DEVICE),baud=115200' reset

flash_clean: clean_zmk flash

flash_mcuboot: $(BUILD_DIR_MCUBOOT)/$(BINARY_PATH_MCUBOOT)
	openocd -f interface/cmsis-dap.cfg -f nrf52-particle.cfg -c "init" -c "reset init" -c "halt" -c "program $(shell pwd)/$< 0x0 verify reset" -c "exit"

flash_mcuboot_clean: clean flash_mcuboot

init:
	west init -l config
	west update
	west zephyr-export

serial:
	python -m serial --raw $(ZMK_DEVICE) 115200

update:
	west update
