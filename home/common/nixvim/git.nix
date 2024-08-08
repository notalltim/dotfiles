{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  inherit (config.lib.nixvim) mkRaw;
  cfg = config.baseline.nixvim.git;
  nixvim = config.programs.nixvim;
in {
  options = {
    baseline.nixvim.git = {
      enable = mkEnableOption "Enable baseline git configuiration";
    };
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      extraPlugins = [
        pkgs.vimPlugins.nvim-web-devicons
        {
          plugin = pkgs.vimPlugins.git-conflict-nvim;
          config = ''
            :lua require('git-conflict').setup()
          '';
        }
      ];

      plugins.gitsigns.enable = true;

      plugins.telescope.keymaps = mkIf nixvim.plugins.telescope.enable {
        "<leader>gb" = {
          action = "git_branches";
          options = {
            desc = "Search branches";
            silent = true;
          };
        };
        "<leader>gC" = {
          action = "git_commits";
          options = {
            desc = "Search commits (repo)";
            silent = true;
          };
        };
        "<leader>gc" = {
          action = "git_bcommits";
          options = {
            desc = "Search commits (file)";
            silent = true;
          };
        };
        "<leader>gt" = {
          action = "git_status";
          options = {
            desc = "Git status";
            silent = true;
          };
        };
      };

      plugins.which-key.settings.spec = mkIf nixvim.plugins.which-key.enable [
        {
          __unkeyed-1 = "<leader>g";
          desc = "Git";
        }
      ];

      keymapsOnEvents = {
        BufEnter = let
          mkOptions = desc: {
            inherit desc;
            silent = true;
            buffer = true;
          };
        in [
          {
            key = "<leader>gl";
            action = mkRaw "package.loaded.gitsigns.blame_line";
            options = mkOptions "View git blame";
            mode = "n";
          }
          {
            key = "<leader>gL";
            action = mkRaw "function() package.loaded.blame_line {full = true} end";
            options = mkOptions "Full git blame";
            mode = "n";
          }
          {
            key = "<leader>gp";
            action = mkRaw "package.loaded.gitsigns.preview_hunk";
            options = mkOptions "Preview git hunk";
            mode = "n";
          }
          {
            key = "<leader>gr";
            action = mkRaw "package.loaded.gitsigns.reset_hunk";
            options = mkOptions "Reset git hunk";
            mode = "n";
          }
          {
            key = "<leader>gR";
            action = mkRaw "package.loaded.gitsigns.reset_buffer";
            options = mkOptions "Reset git buffer";
            mode = "n";
          }
          {
            key = "<leader>gs";
            action = mkRaw "package.loaded.gitsigns.stage_hunk";
            options = mkOptions "Stage git hunk";
            mode = "n";
          }
          {
            key = "<leader>gS";
            action = mkRaw "package.loaded.gitsigns.stage_buffer";
            options = mkOptions "Stage git buffer";
            mode = "n";
          }
          {
            key = "<leader>gu";
            action = mkRaw "package.loaded.gitsigns.undo_stage_hunk";
            options = mkOptions "Unstage git hunk";
            mode = "n";
          }
          {
            key = "<leader>gd";
            action = mkRaw "package.loaded.gitsigns.diffthis";
            options = mkOptions "View git diff";
            mode = "n";
          }
          {
            key = "<leader>gD";
            action = mkRaw "function() package.loaded.gitsigns.diffthis('~') end";
            options = mkOptions "View git diff (full)";
            mode = "n";
          }
          {
            key = "<leader>gs";
            action = mkRaw "function() package.loaded.gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end";
            options = mkOptions "Stage selection";
            mode = "v";
          }
          {
            key = "<leader>gr";
            action = mkRaw "function() package.loaded.gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end";
            options = mkOptions "Reset selection";
            mode = "v";
          }
          {
            key = "[c";
            action = mkRaw "package.loaded.gitsigns.prev_hunk";
            options = mkOptions "Go to previous hunk";
            mode = "n";
          }
          {
            key = "]c";
            action = mkRaw "package.loaded.gitsigns.next_hunk";
            options = mkOptions "Go to next hunk";
            mode = "n";
          }
          {
            key = "ih";
            action = mkRaw "\':<C-U>Gitsigns select_hunk<CR>\'";
            options = mkOptions "Select hunk";
            mode = ["x" "o"];
          }
        ];
      };
    };
  };
}
