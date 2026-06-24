{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      source ${./config.fish}
    '';
    plugins = [];
  };
}
