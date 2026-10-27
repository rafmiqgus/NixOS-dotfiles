{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [

    # ── cli tools ──────────────────────────────────────────────
    bear
    btop
    cava
    distrobox
    dwt1-shell-color-scripts
    fastfetch
    fd
    feh
    figlet
    fzf
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
    freerdp
    hyprmoncfg
    cloc
    nix-tree
    ncdu
    psmisc
    herdr
    opencode
    lsof
    dmidecode

    # ── dev & build ────────────────────────────────────────────
    cachix
    cmake
    gettext
    gnumake
    devenv
    lld
    lua
    luajitPackages.luarocks
    ninja
    nix-fast-build
    nodejs_24
    pre-commit
    # reuse  # disabled 2026-10-21: nixpkgs 02c087f3 sphinx-hook.sh reads structuredAttrs
    #        # sphinxBuilders as a string -> only "html" runs, `man` output missing, build fails.
    #        # Use `nix run nixpkgs#reuse -- lint` meanwhile; re-enable once fixed upstream.
    tree-sitter
    claude-code
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
    pulseaudio # pactl only (talks to pipewire-pulse); Roadie audio routing needs it
    tectonic
    v4l-utils
    kdePackages.okular
    imagemagick

    # ── color / theming tools ──────────────────────────────────
    matugen
    # pywal16  # disabled 2026-10-21: since nixpkgs #571813 (python __structuredAttrs = true),
    #          # makeWrapperArgs "--prefix PATH : ..." is passed as one arg -> makeWrapper dies.
    #          # Fix pending in NixOS/nixpkgs#575801; re-enable once it reaches nixos-unstable.
    inputs.skwd-wall.packages.${pkgs.stdenv.hostPlatform.system}.default

    # ── apps ───────────────────────────────────────────────────
    ardour
    bitwarden-desktop
    burpsuite
    discord
    keypunch
    libreoffice
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
    obsidian
    upscayl
    microsoft-edge
    lunatask
    teams-for-linux
    ungoogled-chromium
    spotifast

    # ── games ──────────────────────────────────────────────────
    mangohud
    # modrinth-app
    nsnake
    rebels-in-the-sky
    roccat-tools
    steam-run
    tic-80

    # ── tty / console ──────────────────────────────────────────
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
    nixd
    nixfmt-rfc-style
    rust-analyzer
    vtsls

    # ── system libs ────────────────────────────────────────────
    drm_info
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
    pam

    # graphics / gpu
    lsfg-vk
    lsfg-vk-ui
    vulkan-headers
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers

    # ── python & scripts ───────────────────────────────────────
    (pkgs.python313.withPackages (ps: with ps; [
      watchdog 
      pdftotext 
    ]))

    # epiclang wrapper
    (pkgs.writeShellScriptBin "epiclang" ''
      #!/usr/bin/env bash
      exec /home/rafael/Epitech/epiclang/epiclang "$@"
    '')

    # ── Libs ───────────────────────────────────────
    libsecret

    # ── MCPs ─────────────────────────────────────── 
    mcp-nixos
  ];
}
