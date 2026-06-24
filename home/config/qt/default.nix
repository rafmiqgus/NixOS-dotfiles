{ pkgs, ... }:

{
  home.packages = with pkgs; [
    libsForQt5.qt5ct
    kdePackages.qt6ct
    adwaita-qt6
  ];

  qt = {
    enable = true;
    platformTheme.name = "kde";
    # Use Plasma's QQC2 style; avoids missing "breeze"/"adwaita-dark" modules in plasmashell.
    style.name = "org.kde.desktop";
    kde.settings = {
      kdeglobals.General.ColorScheme = "Matugen";
    };
  };
}
