{ pkgs, ... }:

{
  # KDE platform theme so KF6 apps (dolphin) read their palette from
  # kdeglobals (KColorScheme) — matugen writes the colours there (see the qt2
  # template's post_hook). Widget style stays Adwaita-Dark. plasma-integration
  # (the platform plugin) is installed via home/config/kde/default.nix.
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "adwaita-dark";
  };
}
