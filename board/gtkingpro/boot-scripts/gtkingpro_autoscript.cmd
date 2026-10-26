echo "GT-King Pro Volumio boot: checking boot media..."
store disprotect key

setenv bootargs "console=ttyAML0,115200n8 console=ttyS0,115200 console=tty0 earlycon=aml-uart,0xff803000 no_console_suspend loglevel=8 nosplash use_kmsg=yes rootwait net.ifnames=0 elevator=noop maxcpus=6 consoleblank=0 hwdevice=gtkingpro imgpart=UUID=%%IMG_UUID%% bootpart=UUID=%%BOOT_UUID%% datapart=UUID=%%DATA_UUID%% uuidconfig=config.ini imgfile=/volumio_current.sqsh"

# 1. SD Card boot
if fatload mmc 0 0x01080000 Image || fatload mmc 0:1 0x01080000 Image; then
  echo "GT-King Pro: loaded Image from SD card"
  setenv initrd_ok 0
  if fatload mmc 0 0x13000000 uInitrd || fatload mmc 0:1 0x13000000 uInitrd; then
    echo "GT-King Pro: loaded uInitrd"
    setenv initrd_ok 1
  elif fatload mmc 0 0x13000000 volumio.initrd || fatload mmc 0:1 0x13000000 volumio.initrd; then
    echo "GT-King Pro: loaded volumio.initrd"
    setenv initrd_ok 1
  fi
  setenv dtb_ok 0
  if fatload mmc 0 0x10000000 amlogic/meson-g12b-gtking-pro.dtb || fatload mmc 0:1 0x10000000 amlogic/meson-g12b-gtking-pro.dtb; then
    echo "GT-King Pro: loaded DTB (amlogic/meson-g12b-gtking-pro.dtb)"
    setenv dtb_ok 1
  elif fatload mmc 0 0x10000000 dtb.img || fatload mmc 0:1 0x10000000 dtb.img; then
    echo "GT-King Pro: loaded DTB (dtb.img)"
    setenv dtb_ok 1
  fi
  if test "${dtb_ok}" = "1"; then
    fdt addr 0x10000000
    fdt resize 65536
    echo "GT-King Pro: booting Volumio from SD card..."
    if test "${initrd_ok}" = "1"; then
      booti 0x01080000 0x13000000 0x10000000
    else
      booti 0x01080000 - 0x10000000
    fi
  fi
fi

# 2. USB boot
if fatload usb 0 0x01080000 Image || fatload usb 0:1 0x01080000 Image; then
  echo "GT-King Pro: loaded Image from USB"
  if fatload usb 0 0x13000000 uInitrd || fatload usb 0:1 0x13000000 uInitrd; then
    echo "GT-King Pro: loaded uInitrd from USB"
  fi
  if fatload usb 0 0x10000000 amlogic/meson-g12b-gtking-pro.dtb || fatload usb 0 0x10000000 dtb.img; then
    fdt addr 0x10000000
    fdt resize 65536
    echo "GT-King Pro: booting Volumio from USB..."
    booti 0x01080000 0x13000000 0x10000000
  fi
fi

echo "GT-King Pro: external boot failed, falling back to eMMC storeboot"
run storeboot
