{ inputs, pkgs, lib, config, ... }:

{
  imports = [
    ./programs
    inputs.nixcord.homeModules.nixcord
  ];

  home = {
    username = "rafael";
    homeDirectory = "/home/rafael";

    stateVersion = "24.05"; # Please read the comment before changing.

    packages = with pkgs; [

      # Utils 
      vim
      wget
      git
      feh
      htop
      lshw
      neofetch
      pciutils
      nvtopPackages.nvidia
      cava
      devenv
      cachix
      fastfetch
      unzip
      git-lfs
      nix-fast-build
      drm_info
      matugen
      pavucontrol
      playerctl
      fzf
      neovim
      git-credential-manager

      # Apps
      bitwarden-desktop
      kitty
      notesnook
      parabolic
      mission-center
      keypunch
      mangohud
      modrinth-app
      prismlauncher
      firefox-devedition
      libreoffice
      hyprlock
      pywalfox-native

      # System 
      vulkan-headers
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
      reuse
      nodejs_23
      cmake
      gnumake
      pre-commit
      clang-tools
      ninja
      gcc14
      kdePackages.extra-cmake-modules
      gettext
      libsForQt5.full
      flatpak
      python3Full
      gtk3
      ncurses

      # Fonts 
      nerd-fonts.hack
      sf-mono-liga-bin
    ];

    sessionVariables = {
      TERM = "kitty";
    };
  };
  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.git = {
    extraConfig.credential.helper = "manager";
    extraConfig.credential."https://github.com".username = "rafmiqgus";
    extraConfig.credential.credentialStore = "cache";
    enable = true;
  };
}
