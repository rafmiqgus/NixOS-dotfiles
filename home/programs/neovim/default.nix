{ config, inputs, ... }:

{
  programs.neovim = {
    enable = false;
    defaultEditor = true;
  };

  #home.file.".config/nvim" = {
  #  recursive = true;
  #  source = ./.;
  #};
}
