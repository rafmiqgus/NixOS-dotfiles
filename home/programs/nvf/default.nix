{ pkgs, lib, inputs, ... }:

{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = false;
    enableManpages = true;
    settings = {
      vim = {
        lazy.enable = false;
      };
    };
  };
}
