{ config, lib, pkgs, ... }:

{
  #  __         ______     ______     __  __     ______    
  # /\ \       /\  __ \   /\  __ \   /\ \/ /    /\  ___\   
  # \ \ \____  \ \ \/\ \  \ \ \/\ \  \ \  _"-.  \ \___  \  
  #  \ \_____\  \ \_____\  \ \_____\  \ \_\ \_\  \/\_____\ 
  #   \/_____/   \/_____/   \/_____/   \/_/\/_/   \/_____/ 

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
      gaps_in = 10;
	    gaps_out = "10,20,20,20";

	    border_size = 3;

	    "col.active_border" = "$primary 0xff595959 $inverse_primary 45deg";
	    "col.inactive_border" = "0xff595959";

	    resize_on_border = true;

	    layout = "dwindle";
    };
    

    decoration = {
      blur = {
        enabled = true;
	      size = 5;
        passes = 4;
        noise = 0.06;
        brightness = 1.5;
        contrast = 1;
        vibrancy = 0.1696;
        new_optimizations = true;
      };

      shadow = {
	      enabled = true;
	      range = 4;
	      render_power = 3;
	      color = "rgba(1a1a1aee)";
	    };

      dim_inactive = false;
      dim_strength = 0.1;
      rounding = 20;
    };
    
    animations = {
	    enabled = "yes, please :)";

	    bezier = [
        "easeOutQuint,0.23,1,0.32,1"
	      "easeInOutCubic,0.65,0.05,0.36,1"
	      "linear,0,0,1,1"
	      "almostLinear,0.5,0.5,0.75,1.0"
	      "quick,0.15,0,0.1,1"
      ];

	    animation = [
        "global, 1, 10, default"
	      "border, 1, 5.39, easeOutQuint"
	      "windows, 1, 4.79, easeOutQuint"
	      "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
	      "windowsOut, 1, 1.49, linear, popin 87%"
	      "fadeIn, 1, 1.73, almostLinear"
	      "fadeOut, 1, 1.46, almostLinear"
	      "fade, 1, 3.03, quick"
	      "layers, 1, 3.81, easeOutQuint"
	      "layersIn, 1, 4, easeOutQuint, fade"
	      "layersOut, 1, 1.5, linear, fade"
	      "fadeLayersIn, 1, 1.79, almostLinear"
	      "fadeLayersOut, 1, 1.39, almostLinear"
	      "workspaces, 1, 1.94, almostLinear, fade"
	      "workspacesIn, 1, 1.21, almostLinear, fade"
	      "workspacesOut, 1, 1.94, almostLinear, fade"
      ];
    };
  };
}
