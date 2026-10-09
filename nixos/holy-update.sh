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
        nh os switch . -- --impure
        printf "\nRebuilding Home-Manager...\n"
        sudo -u rafael -H nh home switch . -- --impure
        printf "\nGarbage Collecting (all profiles, keep 5 / 7d)\n"
        nh clean all --keep 5 --keep-since 7d
        printf "\nDone."
        ;;
    *)
        echo "Cancelled."
        exit 1
        ;;
esac
