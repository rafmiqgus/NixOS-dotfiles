{ config, inputs, lib, pkgs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};

  # matugen writes ~/.cache/matugen/spicetify-color.ini (kept out of git, so the
  # build needs --impure). spicetify-nix bakes the theme at build time, so the
  # runtime ~/.config/spicetify dir is never read; parse the ini here and hand it
  # over as customColorScheme instead. Missing file (matugen never run) falls back
  # to the theme's own colors. Re-run `hms` after a matugen run to apply new colors.
  colorFile = /home/rafael/.cache/matugen/spicetify-color.ini;
  kvRe = "^([A-Za-z0-9_-]+) *= *([0-9A-Fa-f]+) *$";
  parsed = lib.optionalAttrs (builtins.pathExists colorFile) (lib.pipe (builtins.readFile colorFile) [
    (lib.splitString "\n")
    (map (l: builtins.match kvRe l))
    (lib.filter (m: m != null))
    (map (m: { name = builtins.elemAt m 0; value = builtins.elemAt m 1; }))
    builtins.listToAttrs
  ]);
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
