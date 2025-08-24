{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings.decoration.blur = {
    enabled = true;
	  size = 5;
    passes = 4;
    noise = 0.06;
    brightness = 1.5;
    contrast = 1;
    vibrancy = 0.1696;
    new_optimizations = true;
    popups = true;
    popups_ignorealpha = 0.6;
    input_methods = true;
    input_methods_ignorealpha = 0.8;
  };
}
