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
      # 0.49+ also restores maximized state; on Hyprland it caches a bogus
      # "maximized" and every new window opens full size (kitty #10442).
      remember_window_size = false;
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
