{
  pkgs,
  lib,
  config,
  ...
}:

{
  languages.ruby = {
    enable = true;
    bundler.enable = true;
  };
}

