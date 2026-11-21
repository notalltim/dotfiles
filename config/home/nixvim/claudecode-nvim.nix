{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.baseline.claudecode-nvim;
in
{
  options.baseline.claudecode-nvim = {
    enable = mkEnableOption "Enable claudecode.nvim integration";
    src = lib.mkOption {
      type = lib.types.pathInStore;
      description = "Source for the plugin";
      default = pkgs.fetchFromGitHub {
        owner = "coder";
        repo = "claudecode.nvim";
        rev = "6ad8e0fdbda84486f13f7f1fa4802942f4877f13";
        sha256 = "sha256-omHrOlIFqRbiEO3Oqr5DNnlq04C69bzS567PgplBGKc=";
      };

    };
  };
  config = mkIf cfg.enable {
    programs.nixvim = {
      extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
          pname = "claudecode.nvim";
          version = "main";
          inherit (cfg) src;
        })
      ];

      keymaps = [
        {
          mode = "n";
          key = "<leader>ac";
          action = "<cmd>ClaudeCode<cr>";
          options.desc = "Toggle Claude";
        }
        {
          mode = "n";
          key = "<leader>af";
          action = "<cmd>ClaudeCodeFocus<cr>";
          options.desc = "Focus Claude";
        }
        {
          mode = "n";
          key = "<leader>ar";
          action = "<cmd>ClaudeCode --resume<cr>";
          options.desc = "Resume Claude";
        }
        {
          mode = "n";
          key = "<leader>aC";
          action = "<cmd>ClaudeCode --continue<cr>";
          options.desc = "Continue Claude";
        }
        {
          mode = "n";
          key = "<leader>am";
          action = "<cmd>ClaudeCodeSelectModel<cr>";
          options.desc = "Select Claude model";
        }
        {
          mode = "n";
          key = "<leader>ab";
          action = "<cmd>ClaudeCodeAdd %<cr>";
          options.desc = "Add current buffer";
        }
        {
          mode = "v";
          key = "<leader>as";
          action = "<cmd>ClaudeCodeSend<cr>";
          options.desc = "Send to Claude";
        }
        {
          mode = "n";
          key = "<leader>aa";
          action = "<cmd>ClaudeCodeDiffAccept<cr>";
          options.desc = "Accept diff";
        }
        {
          mode = "n";
          key = "<leader>ad";
          action = "<cmd>ClaudeCodeDiffDeny<cr>";
          options.desc = "Deny diff";
        }
      ];

      extraConfigLua = ''
        require("claudecode").setup(
          {
            terminal = {
              provider = "external",
              provider_opts = {
                external_terminal_cmd = "zellij action new-pane --cwd %s --direction right -- %s",
              },
            },
          }
        )
      '';
    };
  };
}
