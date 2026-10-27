#!/usr/bin/env bash
# Volumio community port for Beelink GT-King Pro (Amlogic S922X-H / G12B).
# Removable-media bring-up: keeps the factory eMMC bootloader untouched.

DEVICE_SUPPORT_TYPE="C"
DEVICE_STATUS="P"

BASE="Debian"
ARCH="armhf"
BUILD="armv7"
UINITRD_ARCH="arm64"

DEVICEFAMILY="gtkingpro"
DEVICENAME="Beelink GT-King Pro"
DEVICEREPO=""

VOLVARIANT=no
MYVOLUMIO=no
VOLINITUPDATER=yes
KIOSKMODE=no
DEBUG_IMAGE="yes"
PLYMOUTH_THEME=""

BOOT_START=1
BOOT_END=128
IMAGE_END=4416
BOOT_TYPE=msdos
BOOT_USE_UUID=yes
INIT_TYPE="initv3"

MODULES=("overlay" "squashfs" "nls_cp437" "nls_utf8")
PACKAGES=("iw" "wireless-regdb" "wpasupplicant" "alsa-utils" "libsdl2-2.0-0" "libegl1" "libgl1" "libgl1-mesa-dri")

write_device_files() {
  log "Installing GT-King Pro boot files, modules and firmware" "ext"
  cp -a --no-preserve=ownership "${PLTDIR}/${DEVICE}/boot/." "${ROOTFSMNT}/boot/"
  cp -a --no-preserve=ownership "${PLTDIR}/${DEVICE}/lib/modules" "${ROOTFSMNT}/lib/"
  cp -a --no-preserve=ownership "${PLTDIR}/${DEVICE}/lib/firmware" "${ROOTFSMNT}/lib/"

  # Install the verified GT-King Pro DTB
  local dtb_source="${SRC}/../../board/gtkingpro/boot/amlogic/meson-g12b-gtking-pro.dtb"
  [[ -f "${dtb_source}" ]] || { log "GT-King Pro DTB missing: ${dtb_source}" "err"; return 1; }
  install -D -m 0644 "${dtb_source}" "${ROOTFSMNT}/boot/amlogic/meson-g12b-gtking-pro.dtb"

  # Install aml_autoscript and gtkingpro_autoscript
  local aml_autoscript_src="${SRC}/../../board/gtkingpro/boot/aml_autoscript"
  [[ -f "${aml_autoscript_src}" ]] || { log "aml_autoscript missing: ${aml_autoscript_src}" "err"; return 1; }
  install -D -m 0644 "${aml_autoscript_src}" "${ROOTFSMNT}/boot/aml_autoscript"

  local gtking_autoscript_src="${SRC}/../../board/gtkingpro/boot/gtkingpro_autoscript"
  [[ -f "${gtking_autoscript_src}" ]] || { log "gtkingpro_autoscript missing: ${gtking_autoscript_src}" "err"; return 1; }
  install -D -m 0644 "${gtking_autoscript_src}" "${ROOTFSMNT}/boot/gtkingpro_autoscript"

  # Enable ssh by default
  touch "${ROOTFSMNT}/boot/ssh"
}

write_device_bootloader() {
  log "GT-King Pro: preserving stock bootloader/DDR (removable-media bring-up)" "info"
  :
}

device_image_tweaks() {
  local overlay="${SRC}/../../overlays/gtkingpro/rootfs"
  if [[ ! -d "${overlay}" ]]; then
    log "GT-King Pro overlay missing: ${overlay}" "err"
    return 1
  fi
  log "Applying GT-King Pro integration overlay" "cfg" "${overlay}"
  rsync -a --exclude='lib/' "${overlay}/" "${ROOTFSMNT}/"
  
  if [[ -d "${overlay}/lib/firmware" ]]; then
    rsync -a "${overlay}/lib/firmware/" "${ROOTFSMNT}/usr/lib/firmware/"
  fi

  local env_file="${ROOTFSMNT}/volumio/.env"
  if [[ -f "${env_file}" ]]; then
    sed -i '/^SINGLE_NETWORK_MODE=/d' "${env_file}"
    printf '\nSINGLE_NETWORK_MODE=false\n' >> "${env_file}"
  fi

  depmod -b "${ROOTFSMNT}" 6.12.108 || true
  test -f "${ROOTFSMNT}/usr/local/sbin/gtkingpro-audio-init"
  test -f "${ROOTFSMNT}/etc/systemd/system/gtkingpro-audio-init.service"
  test -f "${ROOTFSMNT}/volumio/app/plugins/audio_interface/alsa_controller/cards.json"

  # Enable audio init service
  install -d "${ROOTFSMNT}/etc/systemd/system/multi-user.target.wants"
  ln -sfn ../gtkingpro-audio-init.service \
    "${ROOTFSMNT}/etc/systemd/system/multi-user.target.wants/gtkingpro-audio-init.service"

  # Port 80 systemd-socket-proxyd
  install -d "${ROOTFSMNT}/etc/systemd/system/sockets.target.wants"
  ln -sfn ../volumio-http.socket \
    "${ROOTFSMNT}/etc/systemd/system/sockets.target.wants/volumio-http.socket"

  rm -f "${ROOTFSMNT}/etc/systemd/system/multi-user.target.wants/iptables.service"

  # Pre-install Glass Engine for HDMI visualizer & VU meters
  local glass_zip="${SRC}/../../board/gtkingpro/packages/glass-0.10.38.zip"
  if [[ ! -f "${glass_zip}" ]]; then
    log "Downloading Glass Engine package..." "cfg"
    mkdir -p "$(dirname "${glass_zip}")"
    curl -sSL -o "${glass_zip}" "https://raw.githubusercontent.com/yolun/glass-distribution/main/release/0.10.38/glass-0.10.38.zip" || true
  fi
  if [[ -f "${glass_zip}" ]]; then
    log "Pre-installing Glass Engine into image" "cfg"
    local glass_target="${ROOTFSMNT}/volumio/app/plugins/user_interface/glass"
    mkdir -p "${glass_target}"
    unzip -q -o "${glass_zip}" -d "${glass_target}"
    chmod +x "${glass_target}/bin/"*/* "${glass_target}/run_glass.sh" 2>/dev/null || true
    mkdir -p "${glass_target}/asound"
    cp "${glass_target}/Glass.postGlass.5.conf.tmpl" "${glass_target}/asound/Glass.postGlass.5.conf" 2>/dev/null || true
    sed -i "s|var asoundConf = __dirname + '/asound' + asound;|try { fs.mkdirSync(__dirname + '/asound', { recursive: true }); } catch (e) {}; var asoundConf = __dirname + '/asound' + asound;|" "${glass_target}/index.js" 2>/dev/null || true
  fi
}

device_chroot_tweaks_pre() {
  log "Configuring GT-King Pro kernel command line" "cfg"
  if [[ -f /boot/config.ini ]]; then
    sed -i "s/%%VOLUMIO-UUIDPARAMS%%/imgpart=UUID=${UUID_IMG} bootpart=UUID=${UUID_BOOT} datapart=UUID=${UUID_DATA}/" /boot/config.ini
    if [[ "${DEBUG_IMAGE}" == "yes" ]]; then
      sed -i "s/%%VERBOSITY%%/verbosity=loglevel=8 nosplash use_kmsg=yes/" /boot/config.ini
    else
      sed -i "s/%%VERBOSITY%%/verbosity=quiet loglevel=0/" /boot/config.ini
    fi
  fi
  cat <<-EOF >>/etc/sysctl.conf
abi.cp15_barrier=2
EOF
  sed -i "s/^MODULES=.*/MODULES=list/" /etc/initramfs-tools/initramfs.conf
}

device_chroot_tweaks_post() {
  :
}

device_image_tweaks_post() {
  log "GT-King Pro: rendering boot scripts with UUIDs and wrapping uInitrd" "info"

  # 1. Render gtkingpro_autoscript with UUIDs
  local gtking_src="${SRC}/../../board/gtkingpro/boot-scripts/gtkingpro_autoscript.cmd"
  local gtking_tmp="${ROOTFSMNT}/boot/.gtkingpro_autoscript.cmd"
  if [[ -f "${gtking_src}" ]]; then
    sed -e "s/%%IMG_UUID%%/${UUID_IMG}/g" \
        -e "s/%%BOOT_UUID%%/${UUID_BOOT}/g" \
        -e "s/%%DATA_UUID%%/${UUID_DATA}/g" \
        "${gtking_src}" > "${gtking_tmp}"
    mkimage -A arm -O linux -T script -C none -a 0 -e 0 \
      -n "GT-King Pro Volumio Boot" -d "${gtking_tmp}" \
      "${ROOTFSMNT}/boot/gtkingpro_autoscript"
    rm -f "${gtking_tmp}"
  fi

  # 2. Render aml_autoscript, s905_autoscript, boot.scr
  local aml_src="${SRC}/../../board/gtkingpro/boot-scripts/aml_autoscript.cmd"
  local aml_tmp="${ROOTFSMNT}/boot/.aml_autoscript.cmd"
  if [[ -f "${aml_src}" ]]; then
    sed -e "s/%%IMG_UUID%%/${UUID_IMG}/g" \
        -e "s/%%BOOT_UUID%%/${UUID_BOOT}/g" \
        -e "s/%%DATA_UUID%%/${UUID_DATA}/g" \
        "${aml_src}" > "${aml_tmp}"
    mkimage -A arm -O linux -T script -C none -a 0 -e 0 \
      -n "GT-King Pro Multiboot Setup" -d "${aml_tmp}" \
      "${ROOTFSMNT}/boot/aml_autoscript"
    cp "${ROOTFSMNT}/boot/aml_autoscript" "${ROOTFSMNT}/boot/s905_autoscript"
    cp "${ROOTFSMNT}/boot/aml_autoscript" "${ROOTFSMNT}/boot/boot.scr"
    rm -f "${aml_tmp}"
  fi

  # 3. Create root dtb.img copy for maximum compatibility
  if [[ -f "${ROOTFSMNT}/boot/amlogic/meson-g12b-gtking-pro.dtb" ]]; then
    cp "${ROOTFSMNT}/boot/amlogic/meson-g12b-gtking-pro.dtb" "${ROOTFSMNT}/boot/dtb.img"
  fi

  # 4. Wrap volumio.initrd as uInitrd (keeping raw volumio.initrd as fallback)
  if [[ -f "${ROOTFSMNT}/boot/volumio.initrd" ]]; then
    log "GT-King Pro: wrapping volumio.initrd as uInitrd" "info"
    mkimage -A "${UINITRD_ARCH}" -O linux -T ramdisk -C none -a 0 -e 0 \
      -n "uInitrd" -d "${ROOTFSMNT}/boot/volumio.initrd" "${ROOTFSMNT}/boot/uInitrd"
  fi
}

