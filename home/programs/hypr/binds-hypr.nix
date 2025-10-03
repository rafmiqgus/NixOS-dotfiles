{ config, lib, pkgs, ... }:

{
  #  ______     __     __   __     _____     ______    
  # /\  == \   /\ \   /\ "-.\ \   /\  __-.  /\  ___\   
  # \ \  __<   \ \ \  \ \ \-.  \  \ \ \/\ \ \ \___  \  
  #  \ \_____\  \ \_\  \ \_\\"\_\  \ \____-  \/\_____\ 
  #   \/_____/   \/_/   \/_/ \/_/   \/____/   \/_____/ 

  wayland.windowManager.hyprland.settings = {
    
    "$mainMod" = "SUPER";

    bind = [
      "$mainMod, RETURN, exec, $terminal"
      "$mainMod, N, exec, kitty --session .nvim_session"
      "$mainMod, C, killactive"
      "$mainMod, M, exec, /home/rafael/.dotfiles/home/programs/wlogout/wlogout.sh"
      "$mainMod, E, exec, $fileManager"
      "$mainMod, SPACE, togglefloating"
      "$mainMod, P, pseudo, # dwindle"
      #"$mainMod, J, togglesplit, # dwindle"
      "$mainMod, S, exec, rofi -show drun"
      "$mainMod, W, exec, waypaper"

      # Move focus with mainMod + vim motions
      "$mainMod, H, movefocus, l"
      "$mainMod, L, movefocus, r"
      "$mainMod, K, movefocus, u"
      "$mainMod, J, movefocus, d"

      # Switch workspaces with mainMod + [0-9]
      "$mainMod, ampersand, workspace, 1"
      "$mainMod, eacute, workspace, 2"
      "$mainMod, quotedbl, workspace, 3"
      "$mainMod, apostrophe, workspace, 4"
      "$mainMod, parenleft, workspace, 5"
      "$mainMod, minus, workspace, 6"
      "$mainMod, egrave, workspace, 7"
      "$mainMod, underscore, workspace, 8"
      "$mainMod, ccedilla, workspace, 9"
      "$mainMod, agrave, workspace, 10"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "$mainMod SHIFT, ampersand, movetoworkspace, 1"
      "$mainMod SHIFT, eacute, movetoworkspace, 2"
      "$mainMod SHIFT, quotedbl, movetoworkspace, 3"
      "$mainMod SHIFT, apostrophe, movetoworkspace, 4"
      "$mainMod SHIFT, parenleft, movetoworkspace, 5"
      "$mainMod SHIFT, minus, movetoworkspace, 6"
      "$mainMod SHIFT, egrave, movetoworkspace, 7"
      "$mainMod SHIFT, underscore, movetoworkspace, 8"
      "$mainMod SHIFT, ccedilla, movetoworkspace, 9"
      "$mainMod SHIFT, agrave, movetoworkspace, 10"

      # Example special workspace (scratchpad)
      "$mainMod SHIFT, S, movetoworkspace, special:magic"

      # Scroll through existing workspaces with mainMod + scroll
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"

      # clipse
      "$mainMod, V, exec, kitty --class clipse -e 'clipse'"

      # vlock
      "$mainMod SHIFT, L, exec, sudo vlock -an"
    ];

    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    bindel = [
      # Laptop multimedia keys for volume and LCD brightness
      ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];

    bindl = [
      # Requires playerctl
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
  };
}
