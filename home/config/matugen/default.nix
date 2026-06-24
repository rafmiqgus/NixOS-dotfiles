{ config, lib, pkgs, ... }:

{
  home.file.".config/matugen/config.toml".source = ./config.toml;
  home.file.".config/matugen/templates" = {
    source = ./templates;
    recursive = true;
  };
}
