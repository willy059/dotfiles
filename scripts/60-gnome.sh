#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

require_not_root "60-gnome.sh"
command -v dconf >/dev/null || { warn "dconf absent, étape ignorée."; exit 0; }

paths_file="$ROOT_DIR/gnome/dconf-paths.txt"
[[ -s $paths_file ]] || { warn "gnome/dconf-paths.txt vide, rien à restaurer."; exit 0; }

log "Restauration des réglages GNOME"
while IFS= read -r path; do
    f="$ROOT_DIR/gnome/$(dconf_filename "$path")"
    [[ -s $f ]] || continue
    log "  $path <- $(basename "$f")"
    run dconf load "$path" < "$f"
done < <(grep -vE '^\s*(#|$)' "$paths_file")
