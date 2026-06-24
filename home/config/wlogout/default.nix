{ config, inputs, lib, pkgs, ... }:

{
  home.packages = [ pkgs.wlogout ];

  home.file.".config/wlogout/layout".source = ./layout;
  home.file.".config/wlogout/style.css".source = ./style.css;
  home.file.".config/wlogout/icons" = {
    source = ./icons;
    recursive = true;
  };
}
