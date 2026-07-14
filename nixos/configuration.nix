# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.hyprland.enable = true;

  services.seatd.enable = true;
  services.libinput.enable = true;

  # Configure keymap in X11
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
    hwRender = true;
    config = {
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
    ignoreShellProgramCheck = true;
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  hardware.enableAllFirmware = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    firefox
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

    nvidiaPersistenced = true;

    package = config.boot.kernelPackages.nvidiaPackages.production;
  };
  
  boot.kernelParams = [ 
    "nvidia-drm.modeset=1"
    "drm.vrrpoli=1"
  ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_foward" = 1;
  };

  environment.sessionVariables = {
    # Keep globals minimal; per-session (Hyprland) vendor overrides live in home config.
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  users.users.rafael.shell = pkgs.fish;

  nix.settings.trusted-users = [ "root" "rafael" ];

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
    enable = true;
    gamescopeSession.enable = true;
  };

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Your Mouse Name]
    MatchName=Your Mouse Name
    ModelBouncingKeys=1
  '';

  boot.enableContainers = true;

  programs.gpu-screen-recorder.enable = true;
}
