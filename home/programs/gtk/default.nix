{ config, lib, pkgs, ... }:

{
  gtk = {
    enable = true;

    gtk3 = {
      extraConfig = {
        gtk-application_prefer_dark = true;
        gtk-button-images = true;
        gtk-cursor-theme-name = "Sweet-cursors";
        gtk-cursor-theme-size = 24;
        gtk-decoration-layout = "icon:minimize,maximize,close";
        gtk-enable-animations = true;
        gtk-font-name = "Noto Sans,  10";
        gtk-icon-theme-name = "WhiteSur-dark";
        gtk-menu-images = true;
        gtk-modules = "colorreload-gtk-module";
        gtk-primary-button-warps-slider = true;
        gtk-sound-theme-name = "ocean";
        gtk-theme-name = "Orchis-Purple";
        gtk-toolbar-style = 3;
        gtk-xft-dpi = 98304;
      };
    };

    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-cursor-theme-name = "Sweet-cursors";
        gtk-cursor-theme-size = 24;
        gtk-decoration-layout = "icon:minimize,maximize,close";
        gtk-enable-animations = true;
        gtk-font-name = "Noto Sans,  10";
        gtk-icon-theme-name = "WhiteSur-dark";
        gtk-modules = "colorreload-gtk-module";
        gtk-primary-button-warps-slider = true;
        gtk-sound-theme-name = "ocean";
        gtk-theme-name = "Orchis-Purple";
        gtk-xft-dpi = 98304;
      };
    };
  };
  home.file.".config/gtk-3.0/colors.css".source = ./gtk3/colors.css;
  home.file.".config/gtk-4.0/colors.css".source = ./gtk4/colors.css;
}
