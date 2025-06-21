{ config, pkgs, ... }:

{
  # Install Fastfetch
  home.packages = with pkgs; [ fastfetch ];

  programs.fastfetch = {
    enable  = true;
    package = pkgs.fastfetch;

    settings = {
      logo = {
        source = "/home/rafael/.dotfiles/home/programs/fastfetch/computer_flame_ascii.txt";
        height = 18;
        padding = {
          top = 2;
          bottom = 3;
          left = 3;    
          right = 3;
        };
      };

      display = {
        separator = " : ";
      };

      modules = [
        { type   = "custom";
          format = "┌──────────────────────────────────────────┐";
        }

        { type   = "chassis";
          key    = "  󰇺 Chassis";
          format = "{1} {2} {3}";
        }

        { type     = "os";
          key      = "  󰣇 OS";
          format   = "{2}";
          keyColor = "red";
        }

        { type     = "kernel";
          key      = "   Kernel";
          format   = "{2}";
          keyColor = "red";
        }

        { type     = "packages";
          key      = "  󰏗 Packages";
          keyColor = "green";
        }

        { type     = "display";
          key      = "  󰍹 Display";
          format   = "{1}x{2} @ {3}Hz [{7}]";
          keyColor = "green";
        }

        { type     = "terminal";
          key      = "   Terminal";
          keyColor = "yellow";
        }

        { type   = "wm";
          key    = "  󱗃 WM";
          format = "{2}";
          keyColor = "yellow";
        }

        { type   = "custom";
          format = "└──────────────────────────────────────────┘";
        }

        "break"

        { type   = "title";
          key    = "  ";
          format = "{6} {7} {8}";
        }

        { type   = "custom";
          format = "┌──────────────────────────────────────────┐";
        }

        { type     = "cpu";
          key      = "   CPU";
          format   = "{1} @ {7}";
          keyColor = "blue";
        }

        { type     = "gpu";
          key      = "  󰊴 GPU";
          format   = "{1} {2}";
          keyColor = "blue";
        }

        { type     = "gpu";
          key      = "   GPU Driver";
          format   = "{3}";
          keyColor = "magenta";
        }

        { type     = "memory";
          key      = "   Memory ";
          keyColor = "magenta";
        }

        { type     = "disk";
          key      = "  󱦟 OS Age ";
          folders  = "/";
          format   = "{days} days";
          keyColor = "red";
        }

        { type     = "uptime";
          key      = "  󱫐 Uptime ";
          keyColor = "red";
        }

        { type   = "custom";
          format = "└──────────────────────────────────────────┘";
        }

        { type        = "colors";
          paddingLeft = 2;
          symbol      = "circle";
        }

        "break"
      ];
    };
  };
}

