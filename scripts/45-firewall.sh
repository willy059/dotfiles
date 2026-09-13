#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

list="$ROOT_DIR/firewall/ufw-rules.txt"
[[ -s $list ]] || { warn "firewall/ufw-rules.txt vide, rien à ouvrir."; exit 0; }

command -v ufw >/dev/null || run $SUDO pacman -S --needed --noconfirm ufw
run $SUDO systemctl enable --now ufw.service

log "Application des règles ufw"
while IFS='|' read -r spec comment; do
    run $SUDO ufw allow "$spec" comment "$comment"
done < <(grep -vE '^\s*(#|$)' "$list")
