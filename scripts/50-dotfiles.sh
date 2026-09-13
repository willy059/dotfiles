#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

require_not_root "50-dotfiles.sh"

src_root="$ROOT_DIR/config"
[[ -d $src_root ]] || exit 0

files=$(find "$src_root" -mindepth 1 -type f)
[[ -n $files ]] || { warn "config/ vide, aucun dotfile à lier."; exit 0; }

log "Liaison des dotfiles vers \$HOME"
while IFS= read -r src; do
    rel="${src#"$src_root"/}"
    dest="$HOME/$rel"
    mkdir -p "$(dirname "$dest")"

    if [[ -L $dest && $(readlink -f "$dest") == "$src" ]]; then
        continue
    fi
    if [[ -e $dest ]]; then
        backup="$dest.bak-$(date +%Y%m%d%H%M%S)"
        warn "$dest existe déjà, sauvegardé en $backup"
        run mv "$dest" "$backup"
    fi
    run ln -s "$src" "$dest"
done <<< "$files"
