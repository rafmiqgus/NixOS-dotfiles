{ config, lib, pkgs, ...}:

{
  home.packages = with pkgs; [
    awww
    hyprpaper
    waypaper
    wl-clipboard
    clipse
    wayland-utils
    hyprpolkitagent
    swaynotificationcenter
    hyprlock
    hyprpicker

    # wm session tools
    wlr-randr
    wl-mirror
    brightnessctl
    pavucontrol
    playerctl
  ];

  imports = [
    ./general-hypr.nix
    ./binds-hypr.nix
    ./windows-hypr.nix
    ./looks-hypr.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # colors.conf / monitors.conf are sourced first so $primary/$inverse_primary
    # exist before general{} uses them.
    sourceFirst = true;
    # Keep hyprland.conf; HM's new default for stateVersion >= 26.05 is "lua".
    configType = "hyprlang";
    # ambxst owns look & feel: HM appends extraConfig after all settings, so
    # sourcing it here makes its general/decoration/animations take priority.
    extraConfig = ''
      source = ~/.local/share/ambxst/hyprland.conf
    '';
  };
}
