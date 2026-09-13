function maj --description 'alias maj=mirror && sudo pacman -Syu'
    mirror && sudo pacman -Syu $argv
end
