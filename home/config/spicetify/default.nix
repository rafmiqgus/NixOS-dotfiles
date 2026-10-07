{ config, inputs, lib, pkgs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};

  # matugen writes Themes/Comfy/color.ini (tracked in git). spicetify-nix bakes
  # the theme at build time, so the runtime ~/.config/spicetify dir is never
  # read; parse the ini here and hand it over as customColorScheme instead.
  # Re-run `home-manager switch` after a matugen run to apply new colors.
  colorIni = builtins.readFile ../matugen/generated/spicetify-color.ini;
  kvRe = "^([A-Za-z0-9_-]+) *= *([0-9A-Fa-f]+) *$";
  parsed = lib.pipe colorIni [
    (lib.splitString "\n")
    (map (l: builtins.match kvRe l))
    (lib.filter (m: m != null))
    (map (m: { name = builtins.elemAt m 0; value = builtins.elemAt m 1; }))
    builtins.listToAttrs
  ];
in
{
  programs.spicetify = {
    enable = true;
    spotifyPackage = pkgs.spotify;
    enabledExtensions = with spicePkgs.extensions; [
      shuffle
    ];
    theme = spicePkgs.themes.comfy;
    customColorScheme = parsed;
  };
}
