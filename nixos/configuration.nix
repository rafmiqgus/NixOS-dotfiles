# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./linuwu-sense.nix
    ];

  # Kernel: use the nixpkgs default (do NOT pin 6.12). The warm-idle / fan-on
  # symptom is NOT a kernel-version or C-state-table regression — turbostat idle
  # residency is identical on 6.12 and 6.18, and the E-cores reach core-C6 fine.
  # The "C1_ACPI/C2_ACPI/C3_ACPI" state names are just ACPI _CST slot labels
  # (C3_ACPI's MWAIT hint 0x60 is actually hardware C6); intel_idle deliberately
  # has no dedicated table for RPL mobile and uses ACPI _CST — that's expected.
  # Real cause of the ~6 W idle floor, measured via turbostat:
  #   - multi-monitor scanout blocks package PC8 (0% at 3 displays -> 22% at 1)
  #   - scx_lavd kept P-cores in shallow C1 instead of C6/C7 (removed below)
  #   - a few PCIe devices had runtime PM off (powertop.enable below fixes it)

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Keep the ESP (511 MiB) from filling up with kernel+initrd of every generation.
  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostName = "BloodAndTears"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  # Wayland-only session; X11 server not needed (Hyprland sets its own kb layout,
  # console.keyMap handles the VT). services.xserver.xkb only fed X11 sessions.
  services.xserver.enable = false;

  # SDDM on Wayland. Plasma is disabled (never used) to shrink the closure; the
  # KDE apps actually used (dolphin/kate/okular/ark/gwenview) are re-added to
  # systemPackages below. Config files under ~/.config/*kde*/plasma* are kept.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  # Disabling Plasma removed the Breeze SDDM theme (empty theme = bare fallback).
  # sddm-astronaut ships as a systemPackage (below); it needs qtmultimedia/qtsvg.
  services.displayManager.sddm.theme = "sddm-astronaut-theme";
  services.displayManager.sddm.extraPackages = with pkgs.kdePackages; [ qtmultimedia qtsvg ];
  services.desktopManager.plasma6.enable = false;
  programs.hyprland.enable = true;

  services.seatd.enable = true;
  services.libinput.enable = true;

  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # KMS/DRM based virtual terminal
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  services.kmscon = {
    enable = true;
    config = {
      hwaccel = true;
      font-name = "JetBrainsMono Nerd Font Bold";
      font-size = 14;
      multi-monitor = "largest";
      xkb-layout = "fr";
      xkb-variant = "azerty";
      login = "${pkgs.shadow}/bin/login -p -f rafael";
    } // import ../home/config/matugen/generated/kmscon-palette.nix;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;

    wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        # Disable LDAC — libldac-dec 0.0.2 bug causes fatal init failure (nixpkgs regression)
        # Falls back to aptX HD / AAC which are fully functional
        "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" "aptx" "aptx_hd" ];
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rafael = {
    isNormalUser = true;
    description = "Rafael Miqueles Gustafsson";
    extraGroups = [ "networkmanager" "wheel" "docker" "seat" "input" "vboxusers" "wireshark" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  hardware.enableAllFirmware = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # KDE apps kept after disabling Plasma (dolphin is Hyprland's $fileManager).
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.gwenview
    # SDDM login theme (Plasma's Breeze theme is gone).
    sddm-astronaut
  ];

# Flatpak

  services.flatpak.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver   # iHD VAAPI driver → Intel iGPU video decode
      libva-utils          # vainfo, to verify HW decode
    ];
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = true;
    powerManagement.finegrained = false;

    open = true;

    nvidiaSettings = true;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      sync.enable = false;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };

    nvidiaPersistenced = false;

    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # scx_lavd removed: it kept the P-cores in shallow C1 at idle instead of
  # letting them reach C6/C7 (measured with turbostat), which raised the idle
  # power floor and kept the fans on. lavd is latency/gaming-tuned and trades
  # deep idle for responsiveness — not what this laptop wants at idle. Back to
  # the in-kernel EEVDF scheduler (the default, and what ran cool pre-2026-09).
  # services.scx = {
  #   enable = true;
  #   scheduler = "scx_lavd";
  #   extraArgs = [ "--autopower" ];
  # };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
    "vm.watermark_scale_factor" = 150;
    "vm.dirty_bytes" = 268435456;
    "vm.dirty_background_bytes" = 67108864;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  environment.sessionVariables = {
    # Keep globals minimal; per-session (Hyprland) vendor overrides live in home config.
  };

  users.users.rafael.shell = pkgs.fish;
  # System-side fish: sources /etc/set-environment (NH_FLAKE, sessionVariables)
  # and provides completions for system packages. Config itself stays in HM.
  programs.fish.enable = true;

  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0;
      trusted-users = [ "root" "rafael" ];
      # Extra binary caches (keys fetched from cachix API, 2026-09-17).
      substituters = [
        "https://devenv.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    # Weekly hard-link dedup of identical store files.
    optimise.automatic = true;
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;
  };

  # nh: nixos-rebuild / home-manager / GC wrapper.
  #   nh os switch | nh home switch | nh clean all
  # clean.enable runs `nh clean all` weekly and, unlike `sudo nix-collect-garbage -d`,
  # also prunes every user's ~/.local/state/nix/profiles generations.
  programs.nh = {
    enable = true;
    flake = "/home/rafael/.dotfiles";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 3m";
    };
  };

  # virtualisation
  virtualisation = {
    virtualbox.host = {
      enable = true;
      enableKvm = true;
      addNetworkInterface = false;
      enableExtensionPack = true;
    };
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
    docker = {
      enable = true;
    };
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["rafael"]; 

  security.sudo.extraRules = [
    {
      users = ["rafael"];
      runAs = "root";
      commands = [
        { command = "/home/rafael/.nix-profile/bin/vlock -an"; options = ["NOPASSWD"];}
      ];
    }
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" "vboxdrv" "vboxnetflt" "vboxnetadp" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=2 card_label="EOS600D"
  '';

  environment.etc."jdk/21".source = pkgs.jdk21;
  environment.etc."jdk/17".source = pkgs.jdk17;
  environment.etc."jdk/8".source  = pkgs.jdk8;

  programs.nix-ld.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  programs.steam = {
    enable = false;
    # gamescopeSession (the "Steam (gamescope)" Big Picture session at the SDDM
    # login screen) disabled; launch games from the desktop instead.
    gamescopeSession.enable = false;
  };

  boot.enableContainers = true;

  programs.gpu-screen-recorder.enable = true;

  # Governor stays intel_pstate "powersave" (HWP); EPP is owned by power-profiles-daemon.
  services.power-profiles-daemon.enable = true;

  # Enable runtime PM on PCIe devices at boot (sets power/control=auto), the
  # declarative equivalent of `powertop --auto-tune`. Measured: the Realtek NIC
  # and other devices sat at control=on/D0, holding the package out of deep idle.
  # This runs the tuning once on boot; it does not keep a daemon resident.
  powerManagement.powertop.enable = true;
}
