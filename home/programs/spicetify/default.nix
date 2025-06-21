{ config, inputs, pkgs, ... }:

let 
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      shuffle
    ];
    theme = spicePkgs.themes.comfy;
  };

  home.file.".config/spicetify/Themes" = {
    source = ./Themes;
    recursive = true;
  };
}
