{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf mkDefault;
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
        # File icons for telescope and neo-tree
        web-devicons.enable = mkDefault true;

        # Key command help
        which-key.enable = mkDefault true;

        # Buffer line
        lualine.enable = mkDefault true;

        # Make brackets readable
        rainbow-delimiters.enable = mkDefault true;

        # Make TODO: highlighting work
        todo-comments.enable = mkDefault true;

        # File viewer
        neo-tree.enable = mkDefault true;
        # Syntax highlighting
        treesitter = {
          enable = mkDefault true;
          folding = mkDefault true;
          settings = {
            incremental_selection.enable = mkDefault true;
            indent.enable = mkDefault true;
            highlight.enable = mkDefault true;
          };
        };
        treesitter-context.enable = mkDefault true;

        # Show color codes in the editor and a color picker
        ccc = {
          enable = mkDefault true;
          settings.highlighter.auto_enable = mkDefault true;
        };
      };
    };
  };
}
