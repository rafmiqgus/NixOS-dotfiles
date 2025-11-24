{ pkgs, ... }:

{
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt;
    kde.settings = {
      kdeglobals.General.ColorScheme = "Matugen";
    };
  };
}
