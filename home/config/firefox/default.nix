{ config, lib, pkgs, ... }:

{
  programs.firefox.enable = true;
  programs.firefox.configPath = ".mozilla/firefox";

  home.packages = [ pkgs.pywalfox-native ];
}
