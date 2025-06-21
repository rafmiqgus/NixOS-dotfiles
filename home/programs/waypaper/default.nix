{ config, lib, pkgs, ... }:

{
  home.file.".config/waypaper/config.ini".source = config.lib.file.mkOutOfStoreSymlink "/home/rafael/.dotfiles/home/programs/waypaper/config.ini";
}
