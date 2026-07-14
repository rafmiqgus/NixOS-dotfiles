{ inputs, pkgs, system, ... }:

{
  home.packages = with pkgs; [

    # ── cli tools ──────────────────────────────────────────────
    bear
    btop
    cava
    direnv
    distrobox
    dwt1-shell-color-scripts
    eza
    fastfetch
    fd
    feh
    figlet
    fzf
    git
    git-credential-manager
    git-lfs
    inxi
    jq
    lazygit
    lolcat
    lshw
    man-pages
    man-pages-posix
    parted
    pciutils
    physlock
    powertop
    qpdf
    ripgrep
    soco-cli
    speedtest-cli
    tree
    unzip
    usbutils
    vim
    vlock
    wget
    yazi
    yt-dlp
    zip
    openvpn

    # ── dev & build ────────────────────────────────────────────
    cachix
    cmake
    gettext
    gnumake
    inputs.devenv.packages.${system}.devenv
    lld
    lua
    luajitPackages.luarocks
    ninja
    nix-fast-build
    nodejs_24
    pre-commit
    reuse
    tree-sitter
    claude-code
    gemini-cli
    gh

    # ── containers ─────────────────────────────────────────────
    dive
    docker-compose
    podman-compose
    podman-tui

    # ── multimedia ─────────────────────────────────────────────
    ffmpeg
    ghostscript
    gphoto2
    graphicsmagick
    imv
    libgphoto2
    mpv
    obs-studio
    poppler-utils
    tectonic
    v4l-utils

    # ── color / theming tools ──────────────────────────────────
    matugen
    pywal16

    # ── apps ───────────────────────────────────────────────────
    ardour
    bitwarden-desktop
    burpsuite
    chromium
    discord
    firefox-devedition
    keypunch
    libreoffice
    lunar-client
    ncspot
    neovim
    okteta
    p7zip
    parabolic
    qpdfview
    upscaler
    vesktop
    vscode
    telegram-desktop

    # ── games ──────────────────────────────────────────────────
    mangohud
    modrinth-app
    nsnake
    osu-lazer
    rebels-in-the-sky
    roccat-tools
    steam-run
    tic-80

    # ── productivity ───────────────────────────────────────────
    taskwarrior2
    taskwarrior-tui

    # ── tty / console ──────────────────────────────────────────
    kmscon
    tcsh
    xinit

    # ── fonts ──────────────────────────────────────────────────
    nerd-fonts.hack
    noto-fonts
    noto-fonts-color-emoji
    sf-mono-liga-bin

    # ── lsp servers & formatters ───────────────────────────────
    asm-lsp
    basedpyright
    bash-language-server
    fish-lsp
    nil
    nixpkgs-fmt
    rust-analyzer

    # ── system libs ────────────────────────────────────────────
    drm_info
    flatpak
    glib
    gtk3
    kdePackages.extra-cmake-modules
    libffi
    libinput
    libxml2
    llvmPackages_20.libllvm
    mesa
    mesa-demos
    ncurses
    zlib

    # graphics / gpu
    lsfg-vk
    lsfg-vk-ui
    vulkan-headers
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers

    # ── python & scripts ───────────────────────────────────────
    (pkgs.python313.withPackages (ps: with ps; [ watchdog pdftotext ]))

    # epiclang wrapper
    (pkgs.writeShellScriptBin "epiclang" ''
      #!/usr/bin/env bash
      exec /home/rafael/Epitech/epiclang/epiclang "$@"
    '')
  ];
}
