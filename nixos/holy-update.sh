#!/usr/bin/env bash

set -euo pipefail
if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root :( Try sudo $0."
    exit 1
fi

read -p "Are you sure you want to execute the holy update ? It can take some time... [y/n] : " answer
case "$answer" in 
    [yY])
        printf "HERE. WE. GO.\n"
        cd /home/rafael/.dotfiles 
        printf "\nUpdating the flake...\n"
        nix flake update 
        printf "\nRebuilding system...\n"
        nixos-rebuild switch --flake .#BloodAndTears
        printf "\nRebuilding Home-Manager...\n"
        sudo -u rafael -H home-manager switch --flake .#rafael
        printf "\nGarbage Collecting\n"
        nix-collect-garbage -d 
        printf "\nDone."
        ;;
    *)
        echo "Cancelled."
        exit 1
        ;;
esac
