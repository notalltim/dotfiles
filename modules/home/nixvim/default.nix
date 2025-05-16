{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  cfg = config.baseline.nixvim;
in
{
  imports = [
    ./debug.nix
    ./git.nix
    ./lsp.nix
    ./ui.nix
    ./search.nix
    ./completion.nix
  ];
  options = {
    baseline.nixvim = {
      enable = mkEnableOption "Enable the baseline nixvim configuration";
      enableWayland = mkEnableOption "Enable wayland dependent options";
      enableAll = mkEnableOption "Enable all baseline configuration";
      useDefaultPlugins = mkEnableOption "Use default editor plugins";
    };
  };
  config = {
    baseline.nixvim = mkIf cfg.enableAll {
      enable = true;
      lsp.enable = true;
      ui.enable = true;
      git.enable = true;
      debug.enable = true;
      search.enable = true;
      completion.enable = true;
    };

    programs.nixvim = mkIf cfg.enable {
      enable = true;
      defaultEditor = true;
      extraConfigLuaPre = ''
        -- Global undo files
        vim.cmd("set undodir=~/.nvim/undodir")
        vim.cmd("set undofile")
      '';

      globals = {
        mapleader = " ";
      };

      clipboard = {
        register = "unnamedplus";
        providers = {
          wl-copy.enable = cfg.enableWayland;
          xclip.enable = !cfg.enableWayland;
          xsel.enable = !cfg.enableWayland;
        };
      };

      extraPlugins = [
        pkgs.vimPlugins.bufferize-vim
        pkgs.vimPlugins.unicode-vim
      ];

      plugins.comment.enable = true;

      keymaps = [
        {
          key = "<leader>q";
          action = "<cmd>q<cr>";
          options = {
            desc = "Quit";
          };
        }
        {
          key = "<leader>w";
          action = "<cmd>w<cr>";
          options = {
            desc = "Save";
          };
        }
        {
          key = "<leader>Q";
          action = "<cmd>qall<cr>";
          options = {
            desc = "Quit all";
          };
        }
        {
          key = "<leader>n";
          action = "<cmd>new<cr>";
          options = {
            desc = "New file";
          };
        }
        {
          key = "<leader><leader>";
          action = "<cmd>bn<cr>";
          options = {
            desc = "Cycle buffer";
          };
        }
        {
          key = "<leader>tf";
          action = "<cmd>FormatToggle<cr>";
          options = {
            desc = "Toggle formatting";
          };
        }
      ];
    };
  };
}
