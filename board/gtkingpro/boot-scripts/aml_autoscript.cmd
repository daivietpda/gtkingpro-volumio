# Stage 1: loaded by GT-King Pro vendor U-Boot via Update/Recovery.
echo "GT-King Pro Volumio: configuring multiboot environment"

setenv start_autoscript "if fatload mmc 0 0x01020000 gtkingpro_autoscript || fatload mmc 0:1 0x01020000 gtkingpro_autoscript || fatload usb 0 0x01020000 gtkingpro_autoscript; then autoscr 0x01020000; fi"
setenv bootcmd "run start_autoscript; run storeboot"
setenv reboot_mode "normal"
saveenv

echo "GT-King Pro Volumio: chaining to gtkingpro_autoscript"

if fatload mmc 0 0x01020000 gtkingpro_autoscript || fatload mmc 0:1 0x01020000 gtkingpro_autoscript || fatload usb 0 0x01020000 gtkingpro_autoscript; then
  autoscr 0x01020000
fi

echo "GT-King Pro Volumio: fallback direct boot from SD card"
setenv bootargs "console=ttyAML0,115200n8 console=ttyS0,115200 console=tty0 earlycon=aml-uart,0xff803000 no_console_suspend loglevel=8 nosplash use_kmsg=yes rootwait net.ifnames=0 elevator=noop maxcpus=6 consoleblank=0 hwdevice=gtkingpro imgpart=UUID=%%IMG_UUID%% bootpart=UUID=%%BOOT_UUID%% datapart=UUID=%%DATA_UUID%% uuidconfig=config.ini imgfile=/volumio_current.sqsh"

fatload mmc 0 0x01080000 Image || fatload mmc 0:1 0x01080000 Image
fatload mmc 0 0x13000000 uInitrd || fatload mmc 0:1 0x13000000 uInitrd || fatload mmc 0 0x13000000 volumio.initrd || fatload mmc 0:1 0x13000000 volumio.initrd
fatload mmc 0 0x10000000 amlogic/meson-g12b-gtking-pro.dtb || fatload mmc 0:1 0x10000000 amlogic/meson-g12b-gtking-pro.dtb || fatload mmc 0 0x10000000 dtb.img || fatload mmc 0:1 0x10000000 dtb.img
fdt addr 0x10000000
fdt resize 65536
booti 0x01080000 0x13000000 0x10000000

run storeboot
