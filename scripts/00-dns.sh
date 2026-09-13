#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

if ${ASSUME_YES:-false} || ${DRY_RUN:-false}; then
    warn "Étape DNS ignorée (mode --yes/--dry-run, pas de prompt interactif)."
    exit 0
fi

read -r -p "Adresse IP du DNS primaire (Entrée pour ignorer) : " dns_ip
[[ -n $dns_ip ]] || { log "Aucun DNS renseigné, étape ignorée."; exit 0; }

if ! [[ $dns_ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    warn "Adresse IP invalide ($dns_ip), étape ignorée."
    exit 0
fi

con=$(nmcli -t -f NAME connection show --active | head -n1)
[[ -n $con ]] || { warn "Aucune connexion réseau active, étape ignorée."; exit 0; }

log "Application de $dns_ip comme DNS primaire sur la connexion « $con »"
run $SUDO nmcli connection modify "$con" ipv4.dns "$dns_ip" ipv4.ignore-auto-dns yes
run $SUDO nmcli connection up "$con" >/dev/null
