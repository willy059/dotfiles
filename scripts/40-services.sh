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

disabled_list="$ROOT_DIR/services/disabled.txt"
if [[ -s $disabled_list ]]; then
    mapfile -t disabled_units < <(grep -vE '^\s*(#|$)' "$disabled_list")
    log "Désactivation des services systemd (${#disabled_units[@]} unités)"
    for unit in "${disabled_units[@]}"; do
        run $SUDO systemctl disable --now "$unit" || warn "impossible de désactiver $unit"
    done
fi
