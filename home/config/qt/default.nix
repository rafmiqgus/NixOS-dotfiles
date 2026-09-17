{ pkgs, ... }:

{
  # KDE platform theme so KF6 apps (dolphin) read their palette from kdeglobals
  # (KColorScheme); matugen writes those colours (see qt2 template post_hook).
  # No style override for now -> default Breeze widgets with matugen colours.
  qt = {
    enable = true;
    platformTheme.name = "kde";
  };
}
