#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

list="$ROOT_DIR/packages/pacman-remove.txt"
[[ -s $list ]] || { warn "packages/pacman-remove.txt vide, rien à retirer."; exit 0; }

mapfile -t wanted < <(grep -vE '^\s*(#|$)' "$list")
present=()
for pkg in "${wanted[@]}"; do
    pacman -Qq "$pkg" &>/dev/null && present+=("$pkg")
done

if [[ ${#present[@]} -eq 0 ]]; then
    log "Aucun paquet à retirer n'est installé."
    exit 0
fi

log "Suppression des paquets non désirés (${#present[@]}): ${present[*]}"
run $SUDO pacman -Rns --noconfirm "${present[@]}"
