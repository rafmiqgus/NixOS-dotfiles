{ config, lib, pkgs, ... }:

{
  #  ______     ______     __   __     ______     ______     ______     __        
  # /\  ___\   /\  ___\   /\ "-.\ \   /\  ___\   /\  == \   /\  __ \   /\ \       
  # \ \ \__ \  \ \  __\   \ \ \-.  \  \ \  __\   \ \  __<   \ \  __ \  \ \ \____  
  #  \ \_____\  \ \_____\  \ \_\\"\_\  \ \_____\  \ \_\ \_\  \ \_\ \_\  \ \_____\ 
  #   \/_____/   \/_____/   \/_/ \/_/   \/_____/   \/_/ /_/   \/_/\/_/   \/_____/ 
                                                                              
  wayland.windowManager.hyprland.settings = {

    # Sourced FIRST (sourceFirst = true) so matugen $vars exist before use.
    # ambxst's conf is sourced LAST via extraConfig in default.nix so its
    # general/decoration/animations win over the blocks defined here.
    source = [
      "/home/rafael/.cache/matugen/hyprland-colors.conf"
      "/home/rafael/.config/hypr/monitors.conf"
    ];

    "$terminal" = "kitty";
    "$fileManager" = "dolphin";
    "$menu" = "rofi -show drun";

    exec-once = [
      # "swww-daemon && swww restore --transition-type center"
      # "waybar"
      "systemctl --user start hyprpolkitagent"
      # hyprmoncfgd runs via the systemd user service (hyprmoncfgd.service)
    ];
    
    env = [
      "XCURSOR_SIZE,24"
      "XCURSOR_THEME,Adwaita"
      "HYPRCURSOR_SIZE,24"
      "HYPRCURSOR_THEME,Adwaita"
      # No AQ_DRM_DEVICES pin: it is colon-separated, so by-path names
      # (pci-0000:00:02.0-card) break it and Hyprland aborts with "no gpus".
      # Aquamarine picks the iGPU (owns eDP) on its own; dGPU still sleeps.
      # Launch games with `nvidia-offload <cmd>`.
      "LIBVA_DRIVER_NAME,iHD"
      # "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      # "GBM_BACKEND=nvidia-drm"   # was forcing the whole session onto the dGPU (kept it hot)
      "XKB_DEFAULT_LAYOUT,fr"
    ];

    # Monitor layout owned by hyprmoncfg (~/.config/hypr/monitors.conf).
    monitor = [
      #"eDP-1, 1920x1080@144, 0x0, 1, vrr, 1"
      #"DP-1, 2560x1440@144, 1920x0, 1, vrr, 1" # Maison
      #"HDMI-A-2, 1920x1080@60, 1920x0, 1" # BenQ PJ
      #"DP-1, 1920x1080@75, 1920x0, 1, vrr, 1" #Epitech
      #"DP-4, 3440x1440@120, 0x-1440, 1"
      #"DP-6, 1920x1080@60, -1920x-1080, 1"
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

    # cursor:no_hardware_cursors left at default (2 = auto): hardware cursors
    # work on the Intel iGPU; software cursors cost a redraw per move.

    # VRR only in fullscreen (games) to avoid desktop flicker; direct scanout
    # auto skips compositing for fullscreen windows.
    misc.vrr = 2;
    render.direct_scanout = 2;
  };
}
