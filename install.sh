#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
export ROOT_DIR
source "$ROOT_DIR/lib/common.sh"

require_not_root "install.sh"

all_steps=(pacman aur flatpak services dotfiles gnome)
steps=("${all_steps[@]}")
DRY_RUN=false
ASSUME_YES=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --only) IFS=',' read -r -a steps <<< "$2"; shift 2 ;;
        --skip)
            IFS=',' read -r -a skip <<< "$2"
            steps=()
            for s in "${all_steps[@]}"; do
                [[ " ${skip[*]} " == *" $s "* ]] || steps+=("$s")
            done
            shift 2
            ;;
        --dry-run) DRY_RUN=true; shift ;;
        --yes|-y) ASSUME_YES=true; shift ;;
        -h|--help)
            echo "Usage: $0 [--only step1,step2] [--skip step1,step2] [--dry-run] [--yes]"
            echo "Steps: ${all_steps[*]}"
            exit 0
            ;;
        *) die "Option inconnue: $1" ;;
    esac
done
export DRY_RUN ASSUME_YES

for step in "${steps[@]}"; do
    script=$(find "$ROOT_DIR/scripts" -name "*-${step}.sh" | head -n1)
    [[ -n $script ]] || die "Étape inconnue: $step"
    log "=== Étape: $step ==="
    bash "$script"
done

log "Terminé. Redémarre (ou reconnecte-toi) pour que tout prenne effet."
