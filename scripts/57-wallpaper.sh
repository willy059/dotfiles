#!/usr/bin/env bash
set -euo pipefail
source "$ROOT_DIR/lib/common.sh"

require_not_root "57-wallpaper.sh"

repo_url="git@github.com:willy059/wallpaper.git"
pictures_dir=$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")
dest="$pictures_dir/wallpaper"

if [[ -d $dest/.git ]]; then
    log "Mise à jour de $dest"
    run git -C "$dest" pull --ff-only
else
    log "Clonage de $repo_url vers $dest"
    run git clone "$repo_url" "$dest"
fi

log "Lien ~/.config/background -> $dest/background.jpg"
run ln -sf "$dest/background.jpg" "$HOME/.config/background"
