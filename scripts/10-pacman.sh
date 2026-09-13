#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

list="$ROOT_DIR/packages/pacman.txt"
[[ -s $list ]] || { warn "packages/pacman.txt vide, rien à installer."; exit 0; }

log "Mise à jour de la base pacman"
run $SUDO pacman -Syu --noconfirm

log "Installation des paquets officiels ($(wc -l < "$list") paquets)"
mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$list")
run $SUDO pacman -S --needed --noconfirm "${pkgs[@]}"
