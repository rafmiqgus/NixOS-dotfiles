{inputs, pkgs, ... }:

{
  imports = [
    ./programs
  ];

  home = {
    username = "rafael";
    homeDirectory = "/home/rafael";

    stateVersion = "24.05";

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
      # rpi-imager
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
      ripgrep
      luajitPackages.luarocks
      ripgrep
      inputs.copilot-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
      direnv
      parted
      alsa-utils
      mpv
      pre-commit
      netcat-openbsd
      nmap
      metasploit
      libinput
      gphoto2
      libgphoto2
      v4l-utils
      ffmpeg
      imv
      fd
      ghostscript
      tectonic
      mermaid-cli
      lua
      ghidra-bin
      ltrace
      hashcat
      wlr-randr
      wl-mirror
      brightnessctl
      libsForQt5.qt5ct
      kdePackages.qt6ct
      glib

      # apps
      bitwarden-desktop
      kitty
      notesnook
      parabolic
      keypunch
      mangohud
      # modrinth-app
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
      jetbrains.clion
      gitkraken
      discord
      lunar-client
      mangohud
      obs-studio

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
      # llvmPackages_20.clangWithLibcAndBasicRtAndLibcxx
      # llvmPackages_20.clang-unwrapped
      # llvmPackages_20.libllvm
      # llvmPackages_20.llvm
      # llvmPackages.stdenv
      # pkg-config
      zlib
      libxml2
      libffi 
      lld
      ninja
      kdePackages.extra-cmake-modules
      gettext
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
      # python313Packages.watchdog
      (pkgs.python313.withPackages (ps: with ps; [ watchdog ]))

      # epiclang
      (pkgs.writeShellScriptBin "epiclang" ''
        #!/usr/bin/env bash
        exec /home/rafael/Epitech/epiclang/epiclang "$@"
      '')

      # kde themes
      adwaita-qt6
    ];

    sessionPath = [
      "$HOME/"
      "$HOME/.npm-global/bin" 
    ];

    file.".npmrc".text = "prefix=/home/rafael/.npm-global\n";

    sessionVariables = {
      term = "kitty";
      QT_QPA_PLATFORMTHEME = pkgs.lib.mkForce "qt6ct";
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
}
