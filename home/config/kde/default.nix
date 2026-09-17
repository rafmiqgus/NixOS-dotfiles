{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.plasma-integration
    # Breeze QStyle + color-scheme engine: reads kdeglobals colours so KF6 apps
    # (dolphin) follow the matugen palette. Plasma used to pull this in; it must
    # be explicit now that plasma6 is disabled.
    kdePackages.breeze

    # kde-rounded-corners
    # kdePackages.krohnkite
    # libsForQt5.kcoreaddons
    # libsForQt5.kconfig
    # libsForQt5.kconfigwidgets
    # libsForQt5.kguiaddons
    # libsForQt5.ki18n
    # libsForQt5.kiconthemes
    # libsForQt5.kwindowsystem
  ];
}

