{ config, lib, pkgs, ... }:

{
  #  ______     ______     __   __     ______     ______     ______     __        
  # /\  ___\   /\  ___\   /\ "-.\ \   /\  ___\   /\  == \   /\  __ \   /\ \       
  # \ \ \__ \  \ \  __\   \ \ \-.  \  \ \  __\   \ \  __<   \ \  __ \  \ \ \____  
  #  \ \_____\  \ \_____\  \ \_\\"\_\  \ \_____\  \ \_\ \_\  \ \_\ \_\  \ \_____\ 
  #   \/_____/   \/_____/   \/_/ \/_/   \/_____/   \/_/ /_/   \/_/\/_/   \/_____/ 
                                                                              
  wayland.windowManager.hyprland.settings = {

    source = [ "~/.local/share/ambxst/hyprland.conf" "/home/rafael/.dotfiles/home/config/hypr/colors.conf" ];

    "$terminal" = "kitty";
    "$fileManager" = "dolphin";
    "$menu" = "rofi -show drun";

    debug = {
      disable_logs = false;
      enable_stdout_logs = true;
      colored_stdout_logs = true;
      suppress_errors = true;
    };
    
    exec-once = [
      # "swww-daemon && swww restore --transition-type center"
      "setkbxmap fr"
      # "waybar"
      "systemctl --user start hyprpolkitagent"
    ];
    
    env = [
      "XCURSOR_SIZE,24"
      "XCURSOR_THEME,Adwaita"
      "HYPRCURSOR_SIZE,24"
      "HYPRCURSOR_THEME,Adwaita"
      "WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
      "LIBVA_DRIVER_NAME,nvidia"
      # "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "GBM_BACKEND=nvidia-drm"
      "XKB_DEFAULT_LAYOUT,fr"
    ];

    monitor = [
      "eDP-1, 1920x1080@144, 0x0, 1, vrr, 1"
      "DP-1, 2560x1440@144, 1920x0, 1, vrr, 1" # Maison
      "HDMI-A-2, 1920x1080@60, 1920x0, 1" # BenQ PJ
      #"DP-1, 1920x1080@75, 1920x0, 1, vrr, 1" #Epitech
      #", preferred, auto, 1"
    ];
    
    
    misc = {
      force_default_wallpaper = -1;
      disable_hyprland_logo = false;
    };

    input = {
      kb_layout = "fr";
      kb_variant = "";
      kb_model = "";
      kb_options = "";
      kb_rules = "";
      
      follow_mouse = 1;

      touchpad = {
        tap-to-click = true;
        natural_scroll = true;
      };
    };

    gesture = [
      "3, horizontal, workspace"
    ];

    device = [
      {
        name = "logitech-g305-1"; 
        sensitivity = -1;
      }
      {
        name = "elan0518:00-04f3:31fc-touchpad";
        sensitivity = -0.15;
      }
    ];

    cursor = {
      no_hardware_cursors = true;
    };
  };
}
