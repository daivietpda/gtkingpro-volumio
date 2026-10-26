#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
OVERLAY="${PROJECT_ROOT}/overlays/gtkingpro/rootfs"
ROOTFS="${1:-${PROJECT_ROOT}/mnt/rootfs}"

if [[ ! -d "${OVERLAY}" ]]; then
  printf 'GT-King Pro overlay not found: %s\n' "${OVERLAY}" >&2
  exit 1
fi
if [[ ! -d "${ROOTFS}" ]]; then
  printf 'Target rootfs not found: %s\n' "${ROOTFS}" >&2
  exit 1
fi

if command -v rsync >/dev/null 2>&1; then
  rsync -a "${OVERLAY}/" "${ROOTFS}/"
else
  cp -a "${OVERLAY}/." "${ROOTFS}/"
fi

# Keep onboard Wi-Fi available after reboot, including while Ethernet is connected.
ENV_FILE="${ROOTFS}/volumio/.env"
if [[ -f "${ENV_FILE}" ]]; then
  if grep -q '^SINGLE_NETWORK_MODE=' "${ENV_FILE}"; then
    sed -i 's/^SINGLE_NETWORK_MODE=.*/SINGLE_NETWORK_MODE=false/' "${ENV_FILE}"
  else
    printf '\nSINGLE_NETWORK_MODE=false\n' >> "${ENV_FILE}"
  fi
fi

WANTS_DIR="${ROOTFS}/etc/systemd/system/multi-user.target.wants"
mkdir -p "${WANTS_DIR}"
ln -sfn /etc/systemd/system/gtkingpro-audio-init.service "${WANTS_DIR}/gtkingpro-audio-init.service"
ln -sfn /lib/systemd/system/wireless.service "${WANTS_DIR}/wireless.service"

if command -v depmod >/dev/null 2>&1 && [[ -d "${ROOTFS}/lib/modules/6.12.108" ]]; then
  depmod -b "${ROOTFS}" 6.12.108 || true
fi

printf 'Applied GT-King Pro overlay: %s -> %s\n' "${OVERLAY}" "${ROOTFS}"
