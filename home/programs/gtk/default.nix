{ config, lib, pkgs, ... }:

{
  gtk = {
    enable = true;

    gtk3 = {
      theme.name = "adw-gtk3";
      theme.package = pkgs.adw-gtk3;
      extraConfig = {
        gtk-application_prefer_dark-theme = true;
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
        gtk-xft-dpi = 98304;
      };
    };
  };
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;
}
