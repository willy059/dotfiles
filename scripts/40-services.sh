#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

list="$ROOT_DIR/services/enabled.txt"
[[ -s $list ]] || { warn "services/enabled.txt vide, rien à activer."; exit 0; }

log "Activation des services systemd ($(wc -l < "$list") unités)"
mapfile -t units < <(grep -vE '^\s*(#|$)' "$list")
for unit in "${units[@]}"; do
    run $SUDO systemctl enable "$unit" || warn "impossible d'activer $unit (paquet pas encore installé ?)"
done
