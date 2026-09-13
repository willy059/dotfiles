#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

require_not_root "57-wallpaper.sh"

repo_url="git@github.com:willy059/wallpaper.git"
dest="$HOME/wallpaper"

if [[ -d $dest/.git ]]; then
    log "Mise à jour de $dest"
    run git -C "$dest" pull --ff-only
else
    log "Clonage de $repo_url vers $dest"
    run git clone "$repo_url" "$dest"
fi
