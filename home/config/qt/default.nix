{ pkgs, ... }:

{
  # qt5ct/qt6ct and adwaita-qt/adwaita-qt6 are pulled in by the HM qt module
  # from platformTheme.name / style.name. qt6ct's plugin also answers to the
  # "qt5ct" key HM exports, so no QT_QPA_PLATFORMTHEME override is needed.
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "adwaita-dark";
  };
}
