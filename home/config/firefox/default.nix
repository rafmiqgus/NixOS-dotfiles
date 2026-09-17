{ config, lib, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
    configPath = ".mozilla/firefox";
  };

  home.packages = [ pkgs.pywalfox-native ];
}
