{ config, lib, pkgs, ... }:

let
  cursor = config.home.pointerCursor;
in
{
  #  ______     ______     __   __     ______     ______     ______     __        
  # /\  ___\   /\  ___\   /\ "-.\ \   /\  ___\   /\  == \   /\  __ \   /\ \       
  # \ \ \__ \  \ \  __\   \ \ \-.  \  \ \  __\   \ \  __<   \ \  __ \  \ \ \____  
  #  \ \_____\  \ \_____\  \ \_\\"\_\  \ \_____\  \ \_\ \_\  \ \_\ \_\  \ \_____\ 
  #   \/_____/   \/_____/   \/_/ \/_/   \/_____/   \/_/ /_/   \/_/\/_/   \/_____/ 

  # configType = "lua" (default.nix): each attribute renders as hl.<name>(...),
  # lists give one call per element, `_args` gives a multi-argument call.
  # hyprmoncfg's monitors.lua and ambxst's hyprland.lua are loaded LAST
  # (default.nix extraConfig), so ambxst's general/decoration/animations win.
  # hyprpolkitagent: started by its systemd user unit (graphical-session.target).

  wayland.windowManager.hyprland.settings = {

    env = map (kv: { _args = kv; }) [
      # Cursor vars from home.pointerCursor (home.nix). HM only exports them in
      # hm-session-vars.sh, which Hyprland (launched by SDDM) never sources.
      [ "HYPRCURSOR_THEME" cursor.name ]
      [ "HYPRCURSOR_SIZE" (toString cursor.size) ]
      [ "XCURSOR_THEME" cursor.name ]
      [ "XCURSOR_SIZE" (toString cursor.size) ]
      # No AQ_DRM_DEVICES pin: it is colon-separated, so by-path names
      # (pci-0000:00:02.0-card) break it and Hyprland aborts with "no gpus".
      # Aquamarine picks the iGPU (owns eDP) on its own; dGPU still sleeps.
      # Launch games with `nvidia-offload <cmd>`.
      [ "LIBVA_DRIVER_NAME" "iHD" ]
      # [ "GBM_BACKEND" "nvidia-drm" ]   # was forcing the whole session onto the dGPU (kept it hot)
      [ "XKB_DEFAULT_LAYOUT" "fr" ]
    ];

    # Fallback only: real layout owned by hyprmoncfg (~/.config/hypr/monitors.lua).
    monitor = {
      output = "";
      mode = "preferred";
      position = "auto";
      scale = 1;
    };

    config = {
      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
        # VRR only in fullscreen (games) to avoid desktop flicker.
        vrr = 2; # 1 = always, 2 = fullscreen only
      };

      # Direct scanout auto: skips compositing for fullscreen windows.
      render.direct_scanout = 2;

      # cursor.no_hardware_cursors left at default (2 = auto): hardware cursors
      # work on the Intel iGPU; software cursors cost a redraw per move.

      input = {
        kb_layout = "fr";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        touchpad = {
          tap_to_click = true;
          natural_scroll = true;
        };
      };
    };

    gesture = {
      fingers = 3;
      direction = "horizontal";
      action = "workspace";
    };

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
