{ config, lib, pkgs, ... }:

{
  #  __     __     __     __   __     _____     ______     __     __     ______    
  # /\ \  _ \ \   /\ \   /\ "-.\ \   /\  __-.  /\  __ \   /\ \  _ \ \   /\  ___\   
  # \ \ \/ ".\ \  \ \ \  \ \ \-.  \  \ \ \/\ \ \ \ \/\ \  \ \ \/ ".\ \  \ \___  \  
  #  \ \__/".~\_\  \ \_\  \ \_\\"\_\  \ \____-  \ \_____\  \ \__/".~\_\  \/\_____\ 
  #   \/_/   \/_/   \/_/   \/_/ \/_/   \/____/   \/_____/   \/_/   \/_/   \/_____/ 
  
  wayland.windowManager.hyprland.settings = {

    workspace = [
      "1"
      "2"
      "3"
    ];

    windowrule = [
      "float, class:clipse"
      "size 622 652, class:clipe"
      "float, class:waypaper"
      "size 800 700, class:kitty, title:^KittyNmtui$"
      "float, class:kitty, title:^KittyNmtui$"
      "float, class:pavucontrol"
    ];
  };
}
