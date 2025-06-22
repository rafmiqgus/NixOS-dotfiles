{ config, input, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  home.file.".config/nvim" = {
    recursive = true;
    source = ./.;
  };
}
