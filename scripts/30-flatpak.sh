#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

list="$ROOT_DIR/packages/flatpak.txt"
[[ -s $list ]] || { warn "packages/flatpak.txt vide, rien à installer."; exit 0; }

command -v flatpak >/dev/null || run $SUDO pacman -S --needed --noconfirm flatpak

if ! flatpak remotes | grep -q flathub; then
    log "Ajout du remote Flathub"
    run $SUDO flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

log "Installation des applications flatpak ($(wc -l < "$list") apps)"
mapfile -t apps < <(grep -vE '^\s*(#|$)' "$list")
run flatpak install -y flathub "${apps[@]}"
