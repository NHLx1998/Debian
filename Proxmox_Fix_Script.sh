#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

header_info() {
  clear
  cat <<"EOF"
    Proxmox VE - Post-Installations-Skript
EOF
}

REQUIRED_VERSION="8.0"

set -euo pipefail
shopt -s inherit_errexit nullglob

msg_info() {
  local msg="$1"
  echo -ne "[INFO] ${msg}..."
}

msg_ok() {
  local msg="$1"
  echo -e "[OK] ${msg}"
}

msg_error() {
  local msg="$1"
  echo -e "${msg}"
}

start_routines() {
  header_info

  CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "SOURCES" --menu "Die Paketquellen von Proxmox VE werden angepasst.

Korrekte Proxmox VE Quellen verwenden?" 14 58 2     "yes" " "     "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    echo "Proxmox VE Quellen werden angepasst..."
    cat <<EOF >/etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main contrib
deb http://deb.debian.org/debian bookworm-updates main contrib
deb http://security.debian.org/debian-security bookworm-security main contrib
EOF
    ;;
  no)
    echo "Proxmox VE Quellen wurden nicht angepasst."
    ;;
  esac

  CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "PVE-ENTERPRISE" --menu "'pve-enterprise'-Repository deaktivieren?" 14 58 2 "ja" " " "nein" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  ja)
    echo "Deaktiviere 'pve-enterprise' Repository..."
    cat <<EOF >/etc/apt/sources.list.d/pve-enterprise.list
# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
EOF
    ;;
  nein)
    echo "'pve-enterprise'-Repository bleibt aktiv."
    ;;
  esac

  echo "Routinen abgeschlossen."
}

header_info

echo -e "
Dieses Skript führt Post-Installations-Routinen durch.
"

while true; do
  read -p "Proxmox VE Post-Installations-Skript starten (j/n)? " jn
  case $jn in
  [Jj]*) break ;;
  [Nn]*) exit;;
  esac
done

CURRENT_VERSION=$(pveversion | awk '{print $2}' | cut -d '/' -f 2 | cut -d '-' -f 1)

if dpkg --compare-versions "$CURRENT_VERSION" ge "$REQUIRED_VERSION"; then
  echo "Proxmox VE Version ($CURRENT_VERSION) wird unterstützt."
else
  echo -e "Diese Proxmox-Version ($CURRENT_VERSION) wird nicht unterstützt.
Benötigt wird Version $REQUIRED_VERSION oder höher."
  exit 1
fi

start_routines
