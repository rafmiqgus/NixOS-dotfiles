{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.plasma-integration
    kdePackages.fcitx5-with-addons

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

