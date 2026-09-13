#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

if [[ ${EUID} -eq 0 ]]; then
    SUDO=""
else
    command -v sudo >/dev/null || die "sudo introuvable, installe-le en root d'abord."
    SUDO="sudo"
fi

require_not_root() {
    [[ ${EUID} -ne 0 ]] || die "$1 ne doit pas être lancé en root (utilise ton utilisateur normal, sudo sera appelé au besoin)."
}

confirm() {
    ${DRY_RUN:-false} && return 1
    ${ASSUME_YES:-false} && return 0
    local reply
    read -r -p "$1 [y/N] " reply
    [[ ${reply,,} == y || ${reply,,} == yes ]]
}

dconf_filename() {
    local path="${1#/}"
    path="${path%/}"
    echo "${path//\//_}.dconf"
}

run() {
    if ${DRY_RUN:-false}; then
        printf '[dry-run] %s\n' "$*"
    else
        "$@"
    fi
}
