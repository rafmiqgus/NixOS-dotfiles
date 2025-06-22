{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      nr = "sudo nixos-rebuild switch --flake /home/rafael/.dotfiles#rafael";
      hms = "home-manager switch --flake /home/rafael/.dotfiles/.";
      ll = "ls -la";
      gc = "sudo nix-collect-garbage -d";
      nix-deep-clean = ''
        echo "-> verifying nix-store..." && \
        sudo nix-store --verify --check-contents --repair && \
        echo "-> optimizing store" && \
        sudo nix-store --optimize && \
        echo "-> garbage-collecting..." && \
        sudo nix-collect-garbage -d \
      '';
    };

    oh-my-zsh = {
      enable = true;
      plugins = [];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./.;
        file = "p10k.zsh";
      }
    ];

    initContent = ''
      fastfetch

      if [[ -r "$${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$${(%):-%n}.zsh" ]]; then
        source "$${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$${(%):-%n}.zsh"
      fi

      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
  };

  home.file.".p10k.zsh".source = ./p10k.zsh;
}
