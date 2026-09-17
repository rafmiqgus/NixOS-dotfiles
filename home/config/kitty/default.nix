{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      background_opacity = 0.50;
      enable_audio_bell = false;
      cursor_trail = 1;
      dynamic_background_opacity = true;
      background_blur = 1;
      confirm_os_window_close = 0;
    };
    
    extraConfig = ''
      include /home/rafael/.cache/matugen/kitty-colors.conf
      allow_remote_control yes
    '';
    font = {
      package = pkgs.sf-mono-liga-bin;
      name = "LigaSFMonoNerdFont-Regular";
    };
  };
}
