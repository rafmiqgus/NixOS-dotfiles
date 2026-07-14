{ pkgs, ... }:

{
  packages = with pkgs; [
    cargo
  ];

  languages.rust.enable = true;
}
