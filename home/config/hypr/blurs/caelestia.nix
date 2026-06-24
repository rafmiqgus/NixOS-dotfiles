{ config, lib, pkgs, ...}:

{
  wayland.windowManager.hyprland.settings.decoration.blur = {
    enabled           = true;
    xray              = false;
    special           = false;
    ignore_opacity    = true;
    new_optimizations = true;
    popups            = true;
    input_methods     = true;
    size              = 6;
    passes            = 2;
  };
}
