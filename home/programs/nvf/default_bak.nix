{ pkgs, lib, inputs, ... }:

{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;
    enableManpages = true;

    settings = {
      vim = {
        theme = {
          enable = true;
          name = "oxocarbon";
          style = "dark";
          transparent = false;
        };

        telescope.enable = true;

        lsp = {
          formatOnSave = true; # indent true
          lspkind.enable = false;
          lightbulb.enable = true;
          lspsaga.enable = false;
          trouble.enable = true;
          lspSignature.enable = true;
          otter-nvim.enable = true;
          nvim-docs-view.enable = true;
        };

        languages = {
          enableLSP = true;
          enableTreesitter = true;

          nix.enable = true;
          python.enable = true;
          bash.enable = true;
          markdown.enable = true;
          clang = {
            enable = true;
            lsp.server = "ccls";
          };
          css.enable = true;
          html.enable = true;
          svelte.enable = true;
          typst.enable = true;
        };

        visuals = {
          nvim-scrollbar.enable = true;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          cinnamon-nvim.enable = true;
          fidget-nvim.enable = true;
          highlight-undo.enable = true;
          indent-blankline.enable = true; # indent true
        };

        statusline = {
          lualine = {
            enable = true;
            theme = "gruvbox";
          };
        };

        autopairs.nvim-autopairs.enable = true; # indent true

        autocomplete.nvim-cmp.enable = true;
        snippets.luasnip.enable = true;

        filetree = {
          neo-tree = {
            enable = true;
          };
        };

        tabline = {
          nvimBufferline.enable = true;
        };

        treesitter = {
          context.enable = true;
          indent.enable = true; # indent true
        };

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false;
        };

        minimap = {
          minimap-vim.enable = false;
          codewindow.enable = true; # lighter, faster, and uses lua for configuration
        };

        dashboard = {
          dashboard-nvim.enable = false;
          alpha.enable = false;
        };

        notify = {
          nvim-notify.enable = true;
        };

        utility = {
          ccc.enable = true;
          vim-wakatime.enable = false;
          diffview-nvim.enable = true;
          yanky-nvim.enable = false;
          icon-picker.enable = true;
          surround.enable = true;
          leetcode-nvim.enable = true;
          multicursors.enable = true;
          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = true;
          };
          images = {
            image-nvim.enable = false;
          };
          snacks-nvim = {
            enable = true;
            setupOpts = import ./snacks-opts.nix {};
          };
        };

        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = true;
          };
        };

        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          modes-nvim.enable = false; # the theme looks terrible with catppuccin
          illuminate.enable = true;
          breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
          };
          smartcolumn = {
            enable = true;
            setupOpts.custom_colorcolumn = {
              # this is a freeform module, it's `buftype = int;` for configuring column position
              nix = "110";
              ruby = "120";
              java = "130";
              go = ["90" "130"];
            };
          };
          fastaction.enable = true;
        };

        presence = {
          neocord.enable = true;
        };

        options = {
          expandtab = true;
          tabstop = 4;
          shiftwidth = 4;
          softtabstop = 4;
          autoindent = true; # indent true
        };

        autocmds = [
          {
            enable = true; # indent true
            event = [ "FileType" ];
            pattern = [ "nix" ];
            command = "setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2";
          }
        ];

        globals.editorconfig = true; # indent true
      };
    };
  };
}
