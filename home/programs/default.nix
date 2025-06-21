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
    ./nixcord
    ./matugen
    ./gtk
    ./spicetify
  ];
}
