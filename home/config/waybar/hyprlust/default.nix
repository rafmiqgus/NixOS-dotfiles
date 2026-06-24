{ config, lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    style = builtins.readFile ./style.css;
  };
  xdg.configFile."waybar/config".source = ./wallust_new.json;
  xdg.configFile."waybar/modules".source = ./modules.json;
}
