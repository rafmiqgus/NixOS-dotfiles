{ config, lib, pkgs, ... }:

{
  #  __         ______     ______     __  __     ______    
  # /\ \       /\  __ \   /\  __ \   /\ \/ /    /\  ___\   
  # \ \ \____  \ \ \/\ \  \ \ \/\ \  \ \  _"-.  \ \___  \  
  #  \ \_____\  \ \_____\  \ \_____\  \ \_\ \_\  \/\_____\ 
  #   \/_____/   \/_____/   \/_____/   \/_/\/_/   \/_____/ 

  # Note: ambxst's hyprland.lua is loaded last (see default.nix extraConfig)
  # and overrides the general/decoration/animations set here, including the
  # border colours (so no matugen colours are loaded in Hyprland any more).
  # animations/caelestia.nix is NOT imported: ambxst only sets parent animations
  # (windows/fade/border/workspaces, 2.5), so caelestia's leaves (windowsMove 6,
  # fadeDim 6, ...) survived and made focus/scroll moves take 600 ms.
  imports = [
    ./blurs/caelestia.nix
  ];

  wayland.windowManager.hyprland.settings.config = {

    master = {
      new_status = "master";
    };

    dwindle = {
      # pseudotile option was removed in Hyprland 0.5x; `pseudo` dispatcher still works.
      preserve_split = true;
    };

    general = {
      gaps_in = 8;
      gaps_out = { top = 8; right = 18; bottom = 18; left = 18; };

      border_size = 4;

      resize_on_border = true;

      layout = "dwindle";
    };

    decoration = {
      shadow = {
        enabled = true;
        range = 20;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      };

      dim_inactive = true;
      dim_strength = 0.1;
      rounding = 20;
    };
  };
}
