#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

if ${ASSUME_YES:-false} || ${DRY_RUN:-false}; then
    warn "Étape nom de la machine ignorée (mode --yes/--dry-run, pas de prompt interactif)."
    exit 0
fi

current=$(hostnamectl hostname 2>/dev/null || hostname)
read -r -p "Nom de la machine (actuel: $current, Entrée pour garder) : " new_hostname
[[ -n $new_hostname ]] || { log "Nom inchangé."; exit 0; }

if ! [[ $new_hostname =~ ^[a-zA-Z0-9-]+$ ]]; then
    warn "Nom invalide ($new_hostname : lettres/chiffres/tirets uniquement), étape ignorée."
    exit 0
fi

log "Changement du nom de la machine en « $new_hostname »"
run $SUDO hostnamectl set-hostname "$new_hostname"
