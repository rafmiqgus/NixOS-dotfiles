{ config, pkgs, lib, ... }:

{
  # KDE platform theme so KF6 apps (dolphin) read their palette from kdeglobals
  # (KColorScheme); matugen writes those colours (qt2 template post_hook). The
  # kde theme pulls in the Breeze QStyle. widgetStyle=Breeze must be in
  # kdeglobals or apps fall back to a style that ignores kdeglobals -> white UI.
  qt = {
    enable = true;
    platformTheme.name = "kde";
  };

  # Ensure [KDE] widgetStyle=Breeze in kdeglobals. kwriteconfig6 via
  # qt.kde.settings proved unreliable here, so set it directly (idempotent).
  home.activation.kdeWidgetStyle =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.python3}/bin/python3 ${./ensure-widgetstyle.py}
    '';
}
