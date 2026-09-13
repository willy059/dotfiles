#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
export ROOT_DIR
source "$ROOT_DIR/lib/common.sh"

require_not_root "update.sh"

log "Capture des paquets officiels -> packages/pacman.txt"
comm -23 <(pacman -Qqe | sort) <(pacman -Qqm | sort) > "$ROOT_DIR/packages/pacman.txt"

log "Capture des paquets AUR -> packages/aur.txt"
comm -12 <(pacman -Qqe | sort) <(pacman -Qqm | sort) > "$ROOT_DIR/packages/aur.txt"

if command -v flatpak >/dev/null; then
    log "Capture des applications flatpak -> packages/flatpak.txt"
    flatpak list --app --columns=application > "$ROOT_DIR/packages/flatpak.txt"
fi

log "Capture des services systemd activés -> services/enabled.txt"
systemctl list-unit-files --state=enabled --no-legend | awk '{print $1}' | sort > "$ROOT_DIR/services/enabled.txt"

if command -v dconf >/dev/null; then
    log "Capture des réglages GNOME -> gnome/*.dconf"
    while IFS= read -r path; do
        dconf dump "$path" > "$ROOT_DIR/gnome/$(dconf_filename "$path")"
    done < <(grep -vE '^\s*(#|$)' "$ROOT_DIR/gnome/dconf-paths.txt")
fi

log "Fait. Vérifie le diff avant de commit :"
echo "  git -C '$ROOT_DIR' diff --stat"
