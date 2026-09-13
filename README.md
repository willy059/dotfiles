# dotfiles — réinstallation CachyOS

But : pouvoir repartir d'une CachyOS fraîchement installée (ISO officielle, GNOME)
et retrouver un système utilisable en une commande.

## Utilisation

### Avant une réinstallation (sur la machine actuelle)

Tenir ce dépôt à jour avec l'état réel du système, de temps en temps ou avant
un gros changement :

```
./update.sh
git add -A && git commit -m "update snapshot $(date +%F)"
git push
```

`update.sh` régénère :
- `packages/pacman.txt` — paquets officiels installés explicitement
- `packages/aur.txt` — paquets AUR installés explicitement
- `packages/flatpak.txt` — applications flatpak
- `services/enabled.txt` — services systemd activés
- `gnome/*.dconf` — réglages GNOME (clavier, raccourcis, thème, extensions...)

**Il ne pousse jamais automatiquement vers un remote** — c'est à toi de faire
`git push` une fois que tu as vérifié le diff (`git diff`).

### Après une réinstallation propre

1. Installer CachyOS (ISO GNOME), créer ton compte utilisateur, te connecter.
2. Vérifier la connexion réseau, puis :
   ```
   git clone <URL_DE_TON_REMOTE> ~/dotfiles
   cd ~/dotfiles
   ./install.sh
   ```
3. Se déconnecter/reconnecter (ou redémarrer) pour que les réglages GNOME et
   les groupes utilisateurs (ex: `docker`) prennent effet.

`install.sh` NE doit PAS être lancé en `root` : il utilisera `sudo` lui-même
quand nécessaire. Les paquets AUR (`paru`) refusent de toute façon de
compiler en root.

### Options

```
./install.sh              # tout installe (paquets, aur, flatpak, services, dotfiles, gnome)
./install.sh --only pacman,aur
./install.sh --skip gnome
./install.sh --dry-run
```

## Structure

```
install.sh           point d'entrée pour une réinstallation
update.sh             point d'entrée pour capturer l'état actuel
lib/common.sh         fonctions partagées (log, sudo, confirmations)
scripts/05-remove.sh  désinstalle packages/pacman-remove.txt
scripts/10-pacman.sh  installe packages/pacman.txt
scripts/20-aur.sh     installe paru (si absent) + packages/aur.txt
scripts/30-flatpak.sh installe packages/flatpak.txt
scripts/40-services.sh active services/enabled.txt
scripts/50-dotfiles.sh symlink config/ -> $HOME
scripts/55-gnome-extensions.sh installe gnome/extensions.txt depuis extensions.gnome.org
scripts/60-gnome.sh   restaure gnome/*.dconf (dont l'activation des extensions)
packages/             listes de paquets (éditables à la main)
packages/pacman-remove.txt  paquets par défaut de l'ISO à désinstaller (liste manuelle,
                      non régénérée par update.sh — l'ajouter/l'éditer à la main)
packages/pacman-extra.txt   repère lisible des paquets ajoutés à la main depuis
                      l'install de base (informatif seulement — déjà inclus
                      dans pacman.txt, aucun script ne lit ce fichier)
services/             liste de services systemd
config/               fichiers de config à symlinker dans $HOME (arborescence miroir)
gnome/                dumps dconf par domaine
gnome/extensions.txt  UUID des extensions GNOME Shell à récupérer sur
                      extensions.gnome.org (pas l'AUR : pas de sudo, pas de
                      compilation, version toujours compatible avec le shell
                      installé)
```

## Extensions GNOME Shell

Deux façons de les installer selon le cas :
- **Dépôt officiel/AUR** (ex: dash-to-dock) : ajouter le paquet à
  `packages/pacman.txt` ou `packages/aur.txt` comme n'importe quel paquet.
- **extensions.gnome.org** (ex: blur-my-shell) : ajouter son UUID à
  `gnome/extensions.txt`. Préférable pour les extensions qui n'ont pas de
  paquet officiel propre ou quand on veut éviter une compilation AUR.

Dans les deux cas, l'activation (`enabled-extensions`) est gérée par le dump
`gnome/org_gnome_shell.dconf`, pas par ces listes.

**Limite connue (Wayland)** : une extension fraîchement installée n'est
chargée par GNOME Shell qu'après une déconnexion/reconnexion (ou un
redémarrage) — c'est une limitation de GNOME Shell, pas du script.

## Ajouter un dotfile

Placer le fichier dans `config/` en respectant le chemin relatif à `$HOME`,
par exemple `config/.bashrc` ou `config/.config/fish/config.fish`. Au prochain
`./install.sh`, il sera symlinké vers `$HOME` (l'ancien fichier, s'il existe,
est sauvegardé en `<fichier>.bak-<date>`).

## Notes

- Réactiver un service déjà activé par défaut sur l'ISO CachyOS est sans
  effet (idempotent) : la liste `services/enabled.txt` capture large plutôt
  que de deviner ce qui est "par défaut" vs "ajouté par toi".
- Les dumps `gnome/*.dconf` ne couvrent que quelques répertoires dconf
  pertinents (voir `gnome/dconf-paths.txt`), pas tout `/`, pour éviter d'y
  embarquer de l'historique/des chemins de fichiers récents.
