#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

list="$ROOT_DIR/packages/aur.txt"
[[ -s $list ]] || { warn "packages/aur.txt vide, rien à installer."; exit 0; }

require_not_root "20-aur.sh"

if ! command -v paru >/dev/null; then
    log "paru absent, installation depuis l'AUR"
    run $SUDO pacman -S --needed --noconfirm base-devel git
    tmpdir=$(mktemp -d)
    run git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
    (cd "$tmpdir/paru" && run makepkg -si --noconfirm)
    run rm -rf "$tmpdir"
fi

log "Installation des paquets AUR ($(wc -l < "$list") paquets)"
mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$list")
run paru -S --needed --noconfirm "${pkgs[@]}"
