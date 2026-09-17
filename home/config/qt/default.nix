{ config, pkgs, lib, ... }:

{
  # KDE platform theme so KF6 apps (dolphin) read kdeglobals (KColorScheme);
  # matugen writes those colours (qt2 template post_hook).
  # Widget style = Kvantum with the matugen-rendered theme (see matugen
  # config.toml kvantum_* templates) -> flat Material look in the matugen
  # palette for every Qt app. QT_STYLE_OVERRIDE=kvantum is set by HM.
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "kvantum";
    kvantum = {
      enable = true;
      settings.General.theme = "matugen";
    };
  };

  # Ensure [KDE] widgetStyle=kvantum in kdeglobals so KDE apps pick the style
  # even where QT_STYLE_OVERRIDE is not inherited. kwriteconfig6 via
  # qt.kde.settings proved unreliable here, so set it directly (idempotent).
  home.activation.kdeWidgetStyle =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.python3}/bin/python3 ${./ensure-widgetstyle.py}
    '';
}
