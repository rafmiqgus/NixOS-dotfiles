{ config, lib, pkgs, ... }:

{
  #  __     __     __     __   __     _____     ______     __     __     ______
  # /\ \  _ \ \   /\ \   /\ "-.\ \   /\  __-.  /\  __ \   /\ \  _ \ \   /\  ___\
  # \ \ \/ ".\ \  \ \ \  \ \ \-.  \  \ \ \/\ \ \ \ \/\ \  \ \ \/ ".\ \  \ \___  \
  #  \ \__/".~\_\  \ \_\  \ \_\\"\_\  \ \____-  \ \_____\  \ \__/".~\_\  \/\_____\
  #   \/_/   \/_/   \/_/   \/_/ \/_/   \/____/   \/_____/   \/_/   \/_/   \/_____/

  wayland.windowManager.hyprland.settings = {

    workspace_rule = map (ws: { workspace = ws; }) [ "1" "2" "3" "4" ];

    window_rule = [
      {
        name = "clipse";
        match.class = "^(clipse)$";
        float = true;
        size = "622 652";
      }
      {
        name = "waypaper";
        match.class = "^(waypaper)$";
        float = true;
      }
      {
        name = "kitty-nmtui";
        match = { class = "^(kitty)$"; title = "^(KittyNmtui)$"; };
        float = true;
        size = "800 700";
      }
      {
        name = "pavucontrol";
        match.class = "^(pavucontrol)$";
        float = true;
      }
    ];

    layer_rule = [
      {
        name = "logout-dialog-blur";
        match.namespace = "^(logout_dialog)$";
        blur = true;
      }
    ];
  };
}
