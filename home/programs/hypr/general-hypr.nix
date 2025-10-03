{ config, lib, pkgs, ... }:

{
  #  ______     ______     __   __     ______     ______     ______     __        
  # /\  ___\   /\  ___\   /\ "-.\ \   /\  ___\   /\  == \   /\  __ \   /\ \       
  # \ \ \__ \  \ \  __\   \ \ \-.  \  \ \  __\   \ \  __<   \ \  __ \  \ \ \____  
  #  \ \_____\  \ \_____\  \ \_\\"\_\  \ \_____\  \ \_\ \_\  \ \_\ \_\  \ \_____\ 
  #   \/_____/   \/_____/   \/_/ \/_/   \/_____/   \/_/ /_/   \/_/\/_/   \/_____/ 
                                                                              
  wayland.windowManager.hyprland.settings = {

    "$terminal" = "kitty";
    "$fileManager" = "dolphin";
    "$menu" = "rofi -show drun";
    
    exec-once = [
      "swww-daemon && swww restore --transition-type center"
      "waybar"
      "swaync"
      "systemctl --user start hyprpolkitagent"
    ];
    
    env = [
      "XCURSOR_SIZE,24"
      "HYPRCURSOR,24"
      "WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
      "LIBVA_DRIVER_NAME,nvidia"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "GBM_BACKEND=nvidia-drm"
      "XKB_DEFAULT_LAYOUT,fr"
    ];

    monitor = [
      "eDP-1, 1920x1080@144, 0x0, 1, vrr, 1"
      #"DP-1, 2560x1440@144, 1920x0, 1, vrr, 1" # Maison
      "DP-1, 1920x1080@75, 1920x0, 1, vrr, 1" #Epitech
      ", preferred, auto, 1"
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
        natural_scroll = false;
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
  };
}
