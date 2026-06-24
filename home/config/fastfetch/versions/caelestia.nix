{ config, ... }:

{
  programs.fastfetch = {
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        source = ../nixos_goth.txt;
        position = "top";
        padding = { top = 1; bottom = 2; left = 3; right = 0; };
      };

      display = {
        separator = "  ";
        color = "white";
      };

      modules = [
        "break"
        {
          type = "custom";
          key = "     ╭──────────────────────────────────────────╮";
        }
        {
          type = "kernel";
          key = "     │   kernel";
          format = "{release>29} │";
        }
        {
          type = "command";
          key = "     │   uptime";
          text = "uptime -p | cut -d ' ' -f 2-";
          format = "{>29} │";
        }
        {
          type = "shell";
          key = "     │   shell ";
          format = "{pretty-name>29} │";
        }
        {
          type = "memory";
          key = "     │   mem ";
          format = "{used>19} / {total} │";
        }
        {
          type = "packages";
          key = "     │   pkgs  ";
          format = "{all>29} │";
        }
        {
          type = "command";
          key = "     │   user  ";
          text = "echo $USER";
          format = "{>29} │";
        }
        {
          type = "command";
          key = "     │   hname ";
          text = "hostnamectl hostname";
          format = "{>29} │";
        }
        {
          type = "os";
          key = "     │ 󰻀  distro";
        format = "{pretty-name>29} │";
        }
        {
          type = "custom";
          key = "     ╰──────────────────────────────────────────╯";
        }
        "break"
        "break"
      ];
    };
  };
}

