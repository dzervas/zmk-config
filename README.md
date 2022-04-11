# First time setup

```bash
# You need go, openocd and pip3 system packages. For Arch Linux
sudo pacman -S go openocd python3-pip
# Get imgtool (image signing) & west (building)
pip3 install --user -U imgtool west
# Get MCUmgr (for ZMK flashing)
go get github.com/apache/mynewt-mcumgr-cli/mcumgr
# Init local west
make init
# Install project dependencies
pip3 install --user -r zephyr/scripts/requirements.txt
pip3 install --user -r mcuboot/scripts/requirements.txt
# Generate a signing key (KEEP THIS SAFE)
imgtool keygen -k mcuboot/signing-key-ed25519.pem -t ed25519
```

# Build & Flash MCUBoot

```bash
# Assuming Particle Debugger (CMSIS-DAP) and OpenOCD
make flash_mcuboot
```

# Build & Flash ZMK

Remove the debugger and the board from USB.
Hold the user button and insert the USB in the device so that it enters MCUBoot

```bash
# You can change the serial device by appending FLASH_DEVICE=/dev/ttyACM9
make flash
```

Reset the device and you're done!
