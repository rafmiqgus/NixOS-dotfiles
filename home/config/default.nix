{ config, lib, pkgs, ... }:

{
  imports = [
    ./hypr
    ./kde
    ./firefox
    ./zsh
    ./fastfetch
    ./waybar
    ./kitty
    ./rofi
    ./matugen
    ./gtk
    ./spicetify
    ./hyprlock
    ./wlogout
    ./starship
    ./qt
    ./fish
  ];
}
