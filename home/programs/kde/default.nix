{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    kde-rounded-corners
    polonium
    kdePackages.krohnkite
    libsForQt5.kcoreaddons
    libsForQt5.kconfig
    libsForQt5.kconfigwidgets
    libsForQt5.kguiaddons
    libsForQt5.ki18n
    libsForQt5.kiconthemes
    libsForQt5.kwindowsystem
  ];
}

