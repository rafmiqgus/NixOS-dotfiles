{inputs, pkgs, system, ... }:


{
  imports = [
    ./config
    ./packages.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "rafael";
    homeDirectory = "/home/rafael";

    stateVersion = "24.05";


    sessionPath = [
      "$HOME/.npm-global/bin"
    ];

    file.".npmrc".text = "prefix=/home/rafael/.npm-global\n";

    sessionVariables = {
      term = "kitty";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    pointerCursor = {
      enable = true;
      name = "Adwaita";
      size = 24;
      package = pkgs.adwaita-icon-theme;
      hyprcursor.enable = true;
      hyprcursor.size = 24;
    };
  };
  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "Rafael Miqueles Gustafsson";
      user.email = "rafael.miqueles-gustafsson@epitech.eu";
      credential.helper = "manager";
      credential."https://github.com".username = "rafmiqgus";
      credential.credentialstore = "cache";
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.fcitx5-with-addons = pkgs.kdePackages.fcitx5-with-addons;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "quickjs-2025-09-13-2"
    "electron-39.8.10"
  ];

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # zoxide: `cd` becomes a smart, frecency-ranked jumper (falls back to normal
  # cd for real paths; `cdi` for the interactive picker).
  programs.zoxide = {
    enable = true;
    options = [ "--cmd" "cd" ];
  };

  # eza: modern ls with icons + git status. The `ls`/`la`/`ll`/`lt` aliases in
  # fish config.fish keep the preferred flags (--group-directories-first).
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };

  # bat: cat clone with syntax highlighting (also the MANPAGER).
  programs.bat.enable = true;

  # atuin: searchable SQLite shell history (Ctrl-R). Up-arrow left to fish.
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
  };
}
