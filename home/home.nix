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
      "$HOME/"
      "$HOME/.npm-global/bin" 
    ];

    file.".npmrc".text = "prefix=/home/rafael/.npm-global\n";

    sessionVariables = {
      term = "kitty";
      QT_QPA_PLATFORMTHEME = pkgs.lib.mkForce "qt6ct";
    };

    pointerCursor = {
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
    settings.credential.helper = "manager";
    settings.credential."https://github.com".username = "rafmiqgus";
    settings.credential.credentialstore = "cache";
    enable = true;
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
}
