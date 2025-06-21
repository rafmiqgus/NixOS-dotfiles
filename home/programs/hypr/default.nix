{ config, lib, pkgs, ...}:

{
  home.packages = with pkgs; [
    waybar
    swww
    hyprpaper
    waypaper
    wl-clipboard
    clipse
    wayland-utils
    rofi
    hyprpolkitagent
    swaynotificationcenter
    hyprlock
    hyprpicker
  ];

  imports = [
    ./general-hypr.nix
    ./binds-hypr.nix
    ./looks-hypr.nix
    ./windows-hypr.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    sourceFirst = true;
  };
}
