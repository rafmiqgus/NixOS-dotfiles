{ config, pkgs, ... }:

{
  programs.nixcord = {
    enable = true;  # enable Nixcord. Also installs discord package
    discord.enable = false;
    vesktop.enable = true;
    quickCss = builtins.readFile ./themes/midnight.css;
    config = {
      useQuickCss = true;   # use out quickCSS
      frameless = true; # set some Vencord options
      transparent = true;
      plugins = {
        fakeNitro.enable = true;
        youtubeAdblock.enable = true;
        favoriteEmojiFirst.enable = true;
      };
    };
    extraConfig = {
      # Some extra JSON config here
      # ...
    };
  };
}
