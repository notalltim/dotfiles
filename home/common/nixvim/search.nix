{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  inherit (config.lib.nixvim) mkRaw;
  cfg = config.baseline.nixvim.search;
  nixvim = config.programs.nixvim;
in {
  options = {
    baseline.nixvim.search = {
      enable = mkEnableOption "Enable baseline search configuiration";
    };
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      # symbols for which key maps
      plugins.which-key.settings.spec = mkIf nixvim.plugins.which-key.enable [
        {
          __unkeyed-1 = "<leader>f";
          desc = "File search";
        }
        {
          __unkeyed-1 = "<leader>s";
          desc = "Telescope search";
        }
      ];
      plugins.telescope = {
        enable = true;
        extensions = {
          media-files.enable = true;
          ui-select.enable = true;
          undo.enable = true;
          fzf-native.enable = true;
          # frecency.enable = true;
        };
        keymaps = {
          "<leader>fC" = {
            action = "colorscheme";
            options = {
              desc = "Search colorschemes";
              silent = true;
            };
          };
          "<leader>ff" = {
            action = "find_files";
            options = {
              desc = "Search file names";
              silent = true;
            };
          };
          "<leader>ft" = {
            action = "live_grep";
            options = {
              desc = "Search recent files";
              silent = true;
            };
          };
          "<leader>fr" = {
            action = "oldfiles";
            options = {
              desc = "Git status";
              silent = true;
            };
          };
          "<leader>fc" = {
            action = "grep_string";
            options = {
              desc = "Find string under cursor";
              silent = true;
            };
          };
          "<leader>sh" = {
            action = "help_tags";
            options = {
              desc = "Find in help";
              silent = true;
            };
          };
          "<leader>sm" = {
            action = "man_pages";
            options = {
              desc = "Search man pages";
              silent = true;
            };
          };
          "<leader>sr" = {
            action = "registers";
            options = {
              desc = "Search registers";
              silent = true;
            };
          };
          "<leader>sk" = {
            action = "keymaps";
            options = {
              desc = "Search keymaps";
              silent = true;
            };
          };
          "<leader>sc" = {
            action = "commands";
            options = {
              desc = "Search commands";
              silent = true;
            };
          };
        };
      };
      # This is needed because the telescope keymaps are bit over specified
      keymaps = [
        {
          key = "<leader>fF";
          action = mkRaw "function() require('telescope').find_files({ hidden = true, no_ignore = true }) end";
          options = {
            desc = "Find all files";
            silent = true;
          };
        }
      ];
    };
  };
}
