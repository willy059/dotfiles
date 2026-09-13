function serveur --description 'ssh vers le serveur perso (IP/port définis par scripts/02-serveur-alias.sh)'
    if not set -q serveur_host; or not set -q serveur_port
        echo "serveur_host/serveur_port non définis. Lance ~/dotfiles/install.sh (étape serveur-alias) ou :" >&2
        echo "  fish -c \"set -U serveur_host <ip>; set -U serveur_port <port>\"" >&2
        return 1
    end
    ssh william@$serveur_host -p $serveur_port $argv
end
