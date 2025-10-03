{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "/home/rafael/.dotfiles/home/programs/rofi/themes/style-2.rasi";
  };
  
  home.file.".config/rofi/colors.rasi".source = ./colors.rasi;
  home.file.".config/rofi/matugen-rofi.rasi".source = ./matugen-rofi.rasi;
  home.file.".config/rofi/fonts.rasi".source = ./fonts.rasi;
}
