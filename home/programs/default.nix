{ config, lib, pkgs, ... }:

{
  imports = [
    ./hypr
    ./kde
    ./firefox
    ./zsh
    ./nvf
    ./fastfetch
    ./waybar
    ./kitty
    ./rofi
    ./matugen
    ./gtk
    ./spicetify
    ./neovim
    ./hyprlock
    ./wlogout
    ./starship
    ./qt
    ./textfox
  ];
}
