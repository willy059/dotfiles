#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

require_not_root "02-serveur-alias.sh"

if ${ASSUME_YES:-false} || ${DRY_RUN:-false}; then
    warn "Étape alias serveur ignorée (mode --yes/--dry-run, pas de prompt interactif)."
    exit 0
fi

read -r -p "IP du serveur perso pour l'alias 'serveur' (Entrée pour ignorer) : " host
[[ -n $host ]] || { log "Alias serveur non configuré."; exit 0; }

read -r -p "Port SSH du serveur (Entrée pour 22) : " port
port="${port:-22}"

if ! [[ $port =~ ^[0-9]+$ ]]; then
    warn "Port invalide ($port), étape ignorée."
    exit 0
fi

log "Configuration de l'alias serveur -> $host:$port"
run fish -c "set -U serveur_host '$host'; set -U serveur_port '$port'"
