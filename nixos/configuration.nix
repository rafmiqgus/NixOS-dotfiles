# System configuration for BloodAndTears (Acer Nitro ANV15-51).
# See configuration.nix(5) / `nixos-help`.

{ config, lib, pkgs, ... }:

let
  # matugen output lives outside git (~/.cache/matugen), so rebuilds need --impure.
  kmsconPalette = /home/rafael/.cache/matugen/kmscon-palette.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./linuwu-sense.nix
  ];

  # ── Boot / kernel ──────────────────────────────────────────────
  # Kernel: nixpkgs default (do NOT pin 6.12). The warm-idle / fan-on symptom is
  # not a kernel or C-state regression: turbostat idle residency is identical on
  # 6.12 and 6.18 and E-cores reach core-C6. "C1_ACPI/C2_ACPI/C3_ACPI" are just
  # ACPI _CST slot labels (C3_ACPI's MWAIT hint 0x60 is hardware C6); intel_idle
  # has no RPL-mobile table and uses _CST by design.
  # Real causes of the ~6 W idle floor (turbostat):
  #   - multi-monitor scanout blocks package PC8 (0% at 3 displays -> 22% at 1)
  #   - scx_lavd kept P-cores in shallow C1 instead of C6/C7 (removed, see Power)
  #   - some PCIe devices had runtime PM off (powertop.enable, see Power)
  boot = {
    loader = {
      systemd-boot.enable = true;
      # Keep the 511 MiB ESP from filling up with every generation's kernel+initrd.
      systemd-boot.configurationLimit = 10;
      efi.canTouchEfiVariables = true;
    };

    # nvidia-drm.modeset=1 is added by hardware.nvidia (modesetting/offload).
    # vbox modules are loaded by virtualisation.virtualbox.host (none with enableKvm).
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=2 card_label="EOS600D"
    '';

    kernel.sysctl = {
      # Tuned for zram: swap eagerly, no readahead on swap-in.
      "vm.swappiness" = 180;
      "vm.page-cluster" = 0;
      "vm.watermark_scale_factor" = 150;
      "vm.dirty_bytes" = 268435456; # 256 MiB
      "vm.dirty_background_bytes" = 67108864; # 64 MiB
    };

    enableContainers = true;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  # ── Hardware ───────────────────────────────────────────────────
  hardware = {
    enableAllFirmware = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [ pkgs.intel-media-driver ]; # iHD VAAPI for the iGPU
    };

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = true;
      modesetting.enable = true;
      powerManagement.enable = true;
      nvidiaSettings = true;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true; # provides `nvidia-offload`
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  # ── Networking / locale ────────────────────────────────────────
  networking = {
    hostName = "BloodAndTears";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = lib.genAttrs [
    "LC_ADDRESS"
    "LC_IDENTIFICATION"
    "LC_MEASUREMENT"
    "LC_MONETARY"
    "LC_NAME"
    "LC_NUMERIC"
    "LC_PAPER"
    "LC_TELEPHONE"
    "LC_TIME"
  ] (_: "fr_FR.UTF-8");

  console.keyMap = "fr";

  # ── Desktop ────────────────────────────────────────────────────
  # Wayland-only: no X server. Plasma is disabled (never used) to shrink the
  # closure; the KDE apps actually used are re-added to systemPackages.
  services.xserver = {
    enable = false;
    videoDrivers = [ "nvidia" ]; # read by hardware.nvidia even without X
    # Also the SDDM greeter's keymap.
    xkb = {
      layout = "fr";
      variant = "azerty";
    };
  };

  services.desktopManager.plasma6.enable = false;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    # Breeze left with Plasma; sddm-astronaut (systemPackages) needs qtmultimedia/qtsvg.
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs.kdePackages; [ qtmultimedia qtsvg ];
  };

  programs.hyprland.enable = true;
  services.seatd.enable = true;
  services.libinput.enable = true;

  # KMS/DRM virtual terminal.
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
    }
    # Missing file (matugen never run) = kmscon's default palette.
    // lib.optionalAttrs (builtins.pathExists kmsconPalette) (import kmsconPalette);
  };

  # ── Audio ──────────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # LDAC disabled: libldac-dec 0.0.2 bug causes fatal init failure (nixpkgs
    # regression). Falls back to aptX HD / AAC.
    wireplumber.extraConfig."10-bluez"."monitor.bluez.properties"."bluez5.codecs" = [
      "sbc"
      "sbc_xq"
      "aac"
      "aptx"
      "aptx_hd"
    ];
  };

  # ── Services ───────────────────────────────────────────────────
  services.printing.enable = true;
  services.flatpak.enable = true;

  # ── User ───────────────────────────────────────────────────────
  users.users.rafael = {
    isNormalUser = true;
    description = "Rafael Miqueles Gustafsson";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "seat"
      "input"
      "vboxusers"
      "wireshark"
      "libvirtd"
    ];
    packages = [ pkgs.kdePackages.kate ];
  };

  # System-side fish: sources /etc/set-environment (NH_FLAKE, sessionVariables)
  # and provides completions for system packages. Config itself stays in HM.
  programs.fish.enable = true;

  security.sudo.extraRules = [
    {
      users = [ "rafael" ];
      runAs = "root";
      commands = [
        {
          command = "/home/rafael/.nix-profile/bin/vlock -an";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # ── Packages ───────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # KDE apps kept after disabling Plasma (dolphin is Hyprland's $fileManager).
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.gwenview
    sddm-astronaut # SDDM login theme
    libva-utils # vainfo, to verify HW decode
  ];

  environment.etc = {
    "jdk/21".source = pkgs.jdk21;
    "jdk/17".source = pkgs.jdk17;
    "jdk/8".source = pkgs.jdk8;
  };

  programs.nix-ld.enable = true;
  programs.gpu-screen-recorder.enable = true;
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # default is wireshark-cli (no GUI)
  };

  # ── Nix ────────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
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
    optimise.automatic = true; # weekly hard-link dedup of the store
    # Builds never compete with the desktop.
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;
  };

  # nh: nixos-rebuild / home-manager / GC wrapper.
  # clean.enable runs `nh clean all` weekly; unlike `sudo nix-collect-garbage -d`
  # it also prunes every user's ~/.local/state/nix/profiles generations.
  programs.nh = {
    enable = true;
    flake = "/home/rafael/.dotfiles";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 3m";
    };
  };

  # ── Virtualisation ─────────────────────────────────────────────
  virtualisation = {
    virtualbox.host = {
      # Disabled: KVM + hardening (+ unfree extpack) is never in cache.nixos.org,
      # so every update rebuilt vbox locally (~13 min). libvirtd covers VMs.
      enable = false;
      enableKvm = true;
      addNetworkInterface = false;
      enableExtensionPack = true;
    };
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    spiceUSBRedirection.enable = true;
    docker.enable = true;
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  programs.virt-manager.enable = true;

  # ── Power ──────────────────────────────────────────────────────
  # Governor stays intel_pstate "powersave" (HWP); EPP is owned by power-profiles-daemon.
  services.power-profiles-daemon.enable = true;

  # scx_lavd removed: it kept P-cores in shallow C1 at idle instead of C6/C7
  # (turbostat), raising the idle power floor and keeping the fans on. Back to
  # the in-kernel EEVDF scheduler (what ran cool pre-2026-09).

  # Runtime PM on PCIe devices at boot (power/control=auto), the declarative
  # `powertop --auto-tune`. The Realtek NIC and others sat at control=on/D0,
  # holding the package out of deep idle. One-shot at boot, no resident daemon.
  powerManagement.powertop.enable = true;

  # USB keyboards drop the first keystrokes when waking from autosuspend
  # (powertop --auto-tune sets power/control=auto). Keep any device that
  # exposes a keyboard interface (HID class 03, subclass 01, protocol 01) always on.
  services.udev.extraRules = ''
    ACTION=="add|bind", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_interface", ATTR{bInterfaceClass}=="03", ATTR{bInterfaceSubClass}=="01", ATTR{bInterfaceProtocol}=="01", RUN+="${pkgs.runtimeShell} -c 'echo on > /sys%p/../power/control'"
  '';
  # powertop runs after udev at boot and resets keyboards to auto; re-apply the rule
  powerManagement.powertop.postStart = ''
    ${lib.getExe' config.systemd.package "udevadm"} trigger -c add -s usb \
      -a bInterfaceClass=03 -a bInterfaceSubClass=01 -a bInterfaceProtocol=01
  '';

  # First-install release; do not change (see configuration.nix(5)).
  system.stateVersion = "24.05";
}
