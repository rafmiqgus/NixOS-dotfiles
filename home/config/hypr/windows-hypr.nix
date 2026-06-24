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
      "4"
    ];

    windowrule = [
      "match:class ^(clipse)$, float true"
      "match:class ^(clipse)$, size 622 652"

      "match:class ^(waypaper)$, float true"

      "match:class ^(kitty)$, match:title ^(KittyNmtui)$, size 800 700"
      "match:class ^(kitty)$, match:title ^(KittyNmtui)$, float true"

      "match:class ^(pavucontrol)$, float true"

      "match:class ^(kitty)$, match:title .*nvim.*, opacity 0.90 0.82"
    ];

    layerrule = [
      "match:namespace ^(logout_dialog)$, blur true"
    ];
  };
}
