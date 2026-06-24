{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "/home/rafael/.dotfiles/home/config/rofi/themes/style-2.rasi";
  };
  
  home.file.".config/rofi/colors.rasi".source = ./colors.rasi;
  home.file.".config/rofi/fonts.rasi".source = ./fonts.rasi;
}
