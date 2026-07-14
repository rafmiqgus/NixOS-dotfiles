{
  pkgs,
  lib,
  config,
  ...
}:


{
  languages.python = {
    enable = true;
    venv.enable = true;
  };
}
