{ config, lib, pkgs, ... }:

{
  #  __         ______     ______     __  __     ______    
  # /\ \       /\  __ \   /\  __ \   /\ \/ /    /\  ___\   
  # \ \ \____  \ \ \/\ \  \ \ \/\ \  \ \  _"-.  \ \___  \  
  #  \ \_____\  \ \_____\  \ \_____\  \ \_\ \_\  \/\_____\ 
  #   \/_____/   \/_____/   \/_____/   \/_/\/_/   \/_____/ 

  imports = [
    ./animations/caelestia.nix
    ./blurs/caelestia.nix
  ];

  wayland.windowManager.hyprland.settings = {

    source = "/home/rafael/.dotfiles/home/programs/hypr/colors.conf";

    master = {
      new_status = "master";
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    general = {
      gaps_in = 8;
      gaps_out = "8,18,18,18";

      border_size = 4;

      "col.active_border" = "$primary 0xff595959 $inverse_primary 45deg";
      "col.inactive_border" = "0xff595959";

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
