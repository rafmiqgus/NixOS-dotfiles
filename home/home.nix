{inputs, pkgs, lib, config, ... }:

{
  imports = [
    ./programs
  ];

  home = {
    username = "rafael";
    homeDirectory = "/home/rafael";

    stateVersion = "24.05"; # please read the comment before changing.

    packages = with pkgs; [

      # utils 
      vim
      wget
      git
      feh
      btop
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
      git-credential-manager
      lazygit
      dwt1-shell-color-scripts
      bear
      cmake
      pipx
      jq
      pywal16
      wf-recorder
      graphicsmagick
      rpi-imager
      soco-cli
      speedtest-cli
      distrobox
      dive
      podman-tui
      docker-compose
      podman-compose
      tree
      vlock
      physlock
      valgrind
      criterion
      gcovr
      man-pages
      man-pages-posix
      yt-dlp
      ffmpeg_6

      # apps
      bitwarden-desktop
      kitty
      notesnook
      parabolic
      keypunch
      mangohud
      modrinth-app
      prismlauncher
      firefox-devedition
      libreoffice
      hyprlock
      pywalfox-native
      qpdfview
      p7zip
      wlogout
      vscode
      vesktop
      neovim
      upscaler
      ida-free

      # system 
      vulkan-headers
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
      reuse
      nodejs_24
      cmake
      gnumake
      pre-commit
      llvmPackages_20.clangWithLibcAndBasicRtAndLibcxx
      llvmPackages_20.clang-unwrapped
      llvmPackages_20.libllvm
      llvmPackages_20.llvm
      llvmPackages.stdenv
      pkg-config
      zlib
      libxml2
      libffi 
      lld
      ninja
      kdePackages.extra-cmake-modules
      gettext
      qt6.full
      flatpak
      gtk3
      ncurses
      mesa
      kdePackages.fcitx5-with-addons
      chromium
      llvmPackages_20.libllvm

      # fonts 
      nerd-fonts.hack
      sf-mono-liga-bin

      # lsp servers + formatters
      nil
      nixpkgs-fmt
      basedpyright
      bash-language-server

      # python libraries
      (pkgs.python312.withPackages (ps: with ps; [ watchdog ]))
    ];

    sessionVariables = {
      term = "kitty";
    };

    sessionPath = [
      "$HOME/"
    ];
  };
  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.git = {
    extraConfig.credential.helper = "manager";
    extraConfig.credential."https://github.com".username = "rafmiqgus";
    extraConfig.credential.credentialstore = "cache";
    enable = true;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.fcitx5-with-addons = pkgs.kdePackages.fcitx5-with-addons;
  };
}
