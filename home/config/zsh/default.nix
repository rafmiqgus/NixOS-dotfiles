{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = false;
    enableCompletion = true;
    autosuggestion.enable = false;
    syntaxHighlighting = {
      enable = true;
      styles = {
        default = "fg=7";
        precommand = "fg=16,underline";
        command = "fg=17,bold";
        builtin = "fg=17,bold";
        alias = "fg=17,bold";
        global-alias = "fg=17,bold";
        suffix-alias = "fg=16,underline";
        globbing = "fg=23,bold";
        unknown-token = "fg=7";
        bracket-error = "fg=24,bold";
        bracket-level-1 = "fg=22,bold";
        bracket-level-2 = "fg=23,bold";
        bracket-level-3 = "fg=20,bold";
        bracket-level-4 = "fg=21,bold";
        bracket-level-5 = "fg=16;bold";
        comment = "fg=8";
        single-hyphen-option = "fg=16";
        double-hyphen-option = "fg=16";
        single-quoted-argument = "fg=25";
        double-quoted-argument = "fg=25";
        redirection = "fg=7";
        command-substitution = "fg=23";
        assign = "fg=21,bold";
      };
    };

    shellAliases = {
      nr = "sudo nixos-rebuild switch --flake /home/rafael/.dotfiles#BloodAndTears";
      hms = "git add -A /home/rafael/.dotfiles && home-manager switch --flake /home/rafael/.dotfiles/.#rafael";
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
      holy-update = "sudo ~/.dotfiles/nixos/holy-update.sh";
      epitech = "distrobox enter Epitech";
      lock = "sudo vlock -an";
      # epiclang = "~/Epitech/epiclang/epiclang";
      epi-clone = "~/Epitech/Piscine/epi-clone.sh";
      epi-check = "~/Epitech/Piscine/check.sh";
      c = "clear";
      pentest = "echo $PWD > /tmp/.pentest_prev_dir && cd /home/rafael/.dotfiles/dev-shells/pentest && devenv shell -- zsh && cd --";
    };

    dirHashes = {
      dot = "/home/rafael/.dotfiles/";
      pr = "/home/rafael/.dotfiles/home/config/";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [];
    };

    plugins = [
      # {
      #   name = "powerlevel10k";
      #   src = pkgs.zsh-powerlevel10k;
      #   file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      # }
      # {
      #   name = "powerlevel10k-config";
      #   src = ./.;
      #   file = "p10k.zsh";
      # }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];

    initContent = ''
      [ -z "$PENTEST_SHELL" ] && fastfetch

      # if [[ -r "$${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$${(%):-%n}.zsh" ]]; then
      #   source "$${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$${(%):-%n}.zsh"
      # fi
      #
      # [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      eval "$(starship init zsh)"
      eval "$(direnv hook zsh)"

      if [[ "$(tty)" == /dev/tty* ]]; then
        export TERM=xterm-256color

        if [[ -z "$ZELLIJ" ]]
    '';

    envExtra = "NIX_BUILD_SHELL=zsh";
  };

  # home.file.".p10k.zsh".source = ./p10k.zsh;
}
