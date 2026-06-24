{ config, lib, pkgs, ...}:

{
  home.packages = with pkgs; [
    waybar
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
    sourceFirst = false;
  };
}
