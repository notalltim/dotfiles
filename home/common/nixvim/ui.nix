{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  cfg = config.baseline.nixvim.ui;
in
{
  options = {
    baseline.nixvim.ui = {
      enable = mkEnableOption "Enable baseline UI configuiration";
    };
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      colorscheme = "nightfox";
      extraPlugins = [ pkgs.vimPlugins.nightfox-nvim ];

      extraConfigLuaPre = ''
        vim.cmd("set expandtab")
        vim.cmd("set tabstop=2")
        vim.cmd("set softtabstop=2")
        vim.cmd("set shiftwidth=2")
        vim.wo.number = true
        vim.wo.relativenumber = true
        vim.o.cmdheight = 0
        vim.opt.termguicolors = true
      '';
      keymaps = [
        # Neo-tree key maps
        {
          key = "<leader>o";
          action = "<cmd>lua if vim.bo.filetype == 'neo-tree' then vim.cmd.wincmd 'p' else vim.cmd.Neotree 'focus' end <cr>";
          options = {
            desc = "Toggle focus to/from neo-tree";
          };
        }
        {
          key = "<leader>e";
          action = "<cmd>Neotree toggle<cr>";
          options = {
            desc = "Toggle neo-tree ui";
          };
        }
      ];

      # UI to see key commands
      plugins = {
        which-key.enable = true;

        # Buffer line
        lualine.enable = true;

        # Make brackets readable
        rainbow-delimiters.enable = true;

        # Make TODO: highlighting work
        todo-comments.enable = true;

        # File viewer
        neo-tree.enable = true;
        # Syntax highlighting
        treesitter = {
          enable = true;
          folding = true;
          settings = {
            incremental_selection.enable = true;
            indent.enable = true;
          };
        };
        treesitter-context.enable = true;

        # Show color codes in the editor and a color picker
        ccc = {
          enable = true;
          settings.highlighter.auto_enable = true;
        };
      };
    };
  };
}
