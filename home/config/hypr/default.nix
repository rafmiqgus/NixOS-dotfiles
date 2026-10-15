{ config, lib, pkgs, ...}:

{
  home.packages = with pkgs; [
    awww
    hyprpaper
    waypaper
    wl-clipboard
    clipse
    wayland-utils
    hyprpolkitagent
    swaynotificationcenter
    hyprlock
    hyprpicker

    # wm session tools
    wlr-randr
    wl-mirror
    brightnessctl
    pavucontrol
    playerctl
  ];

  imports = [
    ./general-hypr.nix
    ./windows-hypr.nix
    ./looks-hypr.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # Writes ~/.config/hypr/hyprland.lua (Hyprland Lua API, hl.*).
    # Generated order: locals, require(extraLuaFiles), settings, extraConfig.
    configType = "lua";

    # Native Lua files, require()d before settings.
    extraLuaFiles.binds = ./binds.lua;

    # Loaded last so later hl.config() calls win: hyprmoncfg's monitor layout,
    # then ambxst (owns look & feel: general/decoration/animations/borders).
    # Missing files are skipped (monitors.lua is only written by hyprmoncfg once
    # it sees hyprland.lua; ambxst's file appears after its first start).
    extraConfig = ''
      local function load_if_exists(path)
        local chunk = loadfile(path)
        if chunk then chunk() end
      end

      load_if_exists("/home/rafael/.config/hypr/monitors.lua")
      load_if_exists("/home/rafael/.local/share/ambxst/hyprland.lua")
    '';
  };
}
