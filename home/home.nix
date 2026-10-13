{ pkgs, ... }:

let
  # Bibata Modern Classic as ONE theme dir holding both formats:
  # XCursor (cursors/, index.theme) from nixpkgs for GTK/Qt/Xwayland apps, and
  # hyprcursor (manifest.hl, hyprcursors/) from LOSEARDES77's release for Hyprland.
  bibata-modern-classic = pkgs.runCommand "bibata-modern-classic-hyprcursor" {
    hyprSrc = pkgs.fetchurl {
      url = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/v1.1/hypr_Bibata-Modern-Classic.tar.gz";
      hash = "sha256-62TM34Dva021paPpBLLrfAOXXCZZM0d7IFKzGetwT24=";
    };
  } ''
    dir=$out/share/icons/Bibata-Modern-Classic
    mkdir -p $dir
    cp -r ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic/. $dir/
    chmod -R u+w $dir
    tar xzf $hyprSrc -C $dir
  '';
in
{
  imports = [
    ./config
    ./packages.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # ── Home ───────────────────────────────────────────────────────
  home = {
    username = "rafael";
    homeDirectory = "/home/rafael";
    stateVersion = "24.05";

    sessionPath = [ "$HOME/.npm-global/bin" ];
    file.".npmrc".text = "prefix=/home/rafael/.npm-global\n";

    sessionVariables = {
      TERMINAL = "kitty";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    pointerCursor = {
      enable = true;
      name = "Bibata-Modern-Classic";
      size = 20;
      package = bibata-modern-classic;
      gtk.enable = true;
      hyprcursor.enable = true;
    };
  };

  fonts.fontconfig.enable = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.fcitx5-with-addons = pkgs.kdePackages.fcitx5-with-addons;
  };

  # ── Programs ───────────────────────────────────────────────────
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "Rafael Miqueles Gustafsson";
      user.email = "rafael.miqueles-gustafsson@epitech.eu";
      credential = {
        helper = "manager";
        credentialstore = "cache";
        "https://github.com".username = "rafmiqgus";
      };
    };
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # zoxide: `cd` becomes a frecency-ranked jumper (falls back to normal cd for
  # real paths; `cdi` for the interactive picker).
  programs.zoxide = {
    enable = true;
    options = [ "--cmd" "cd" ];
  };

  # eza: ls with icons + git status. The `ls`/`la`/`ll`/`lt` aliases in fish
  # config.fish keep the preferred flags (--group-directories-first).
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };

  # bat: cat with syntax highlighting (also the MANPAGER).
  programs.bat.enable = true;

  # atuin: searchable SQLite shell history (Ctrl-R). Up-arrow left to fish.
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
  };
}
