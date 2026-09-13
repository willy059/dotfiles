#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

list="$ROOT_DIR/firewall/services.txt"
[[ -s $list ]] || { warn "firewall/services.txt vide, rien à autoriser."; exit 0; }

command -v firewall-cmd >/dev/null || run $SUDO pacman -S --needed --noconfirm firewalld
run $SUDO systemctl enable --now firewalld.service

log "Autorisation des services firewalld"
mapfile -t services < <(grep -vE '^\s*(#|$)' "$list")
for svc in "${services[@]}"; do
    run $SUDO firewall-cmd --permanent --add-service="$svc"
done
run $SUDO firewall-cmd --reload
