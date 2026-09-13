#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

require_not_root "55-gnome-extensions.sh"

list="$ROOT_DIR/gnome/extensions.txt"
[[ -s $list ]] || { warn "gnome/extensions.txt vide, rien à installer."; exit 0; }
command -v gnome-extensions >/dev/null || { warn "gnome-extensions absent, étape ignorée."; exit 0; }

shell_version=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)

mapfile -t uuids < <(grep -vE '^\s*(#|$)' "$list")
for uuid in "${uuids[@]}"; do
    log "Extension GNOME (extensions.gnome.org): $uuid"
    info=$(curl -sf "https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${shell_version}") \
        || { warn "  requête échouée pour $uuid"; continue; }
    dl_path=$(python3 -c "import sys,json; print(json.load(sys.stdin).get('download_url',''))" <<< "$info")
    [[ -n $dl_path ]] || { warn "  aucune version compatible avec GNOME Shell $shell_version"; continue; }

    tmpzip=$(mktemp --suffix=.zip)
    run curl -sfL "https://extensions.gnome.org${dl_path}" -o "$tmpzip"
    run gnome-extensions install --force "$tmpzip"
    rm -f "$tmpzip"
done

log "Reconnecte-toi (ou redémarre) pour que GNOME Shell charge les nouvelles extensions."
