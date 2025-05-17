{ config, lib, ... }:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf mkDefault mkOption;
  inherit (lib.types) path nullOr;
  inherit (config.lib.nixvim) mkRaw;
  cfg = config.baseline.nixvim.completion;
in
{
  options = {
    baseline.nixvim.completion = {
      enable = mkEnableOption "Enable baseline completion configuiration";
      codeium = {
        apikey = mkOption {
          type = nullOr path;
          default = null;
          description = "Codeium api key";
        };
      };
    };
  };
  config = mkIf cfg.enable {
    age.secrets.codeium-apikey = mkIf (cfg.codeium.apikey != null) {
      rekeyFile = cfg.codeium.apikey;
      path = "${config.xdg.cacheHome}/nvim/codeium/config.json";
    };

    programs.nixvim = {
      keymaps = [
        {
          key = "<C-b>";
          action = mkRaw "function() require('cmp').mapping.scroll_docs(-4) end";
          options = {
            desc = "Scroll back in completion results";
            silent = true;
          };
        }
        {
          key = "<C-f>";
          action = mkRaw "function() require('cmp').mapping.scroll_docs(4) end";
          options = {
            desc = "Scroll forward in completion results";
            silent = true;
          };
        }
        {
          key = "<C-Space>";
          action = mkRaw "function() require('cmp').mapping.complete() end";
          options = {
            desc = "Complete with current selection";
            silent = true;
          };
        }
        {
          key = "<C-e>";
          action = mkRaw "function() require('cmp').mapping.abort() end";
          options = {
            desc = "Abort completion";
            silent = true;
          };
        }
        {
          key = "<CR>";
          action = mkRaw "function() require('cmp').mapping.confirm({ select = true }) end";
          options = {
            desc = "Select the current results";
            silent = true;
          };
        }
      ];
      plugins = {
        luasnip.enable = mkDefault true;
        windsurf-nvim = {
          enable = mkDefault true;
          settings = {
            enable_chat = mkDefault true;
          };
        };
        cmp = {
          enable = mkDefault true;
          settings = {
            snippet = {
              expand = ''
                function(args)
                  require('luasnip').lsp_expand(args.body)
                end
              '';
            };
            mapping = {
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<CR>" = "cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace, })";
              "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
              "<C-j>" = "cmp.mapping.select_next_item()";
              "<C-k>" = "cmp.mapping.select_prev_item()";
              "<C-d>" = "cmp.mapping.scroll_docs(-4)";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.close()";
            };
            window = {
              completion = {
                border = "solid";
              };
              documentation = {
                border = "solid";
              };
            };

            sources = [
              { name = "luasnip"; }
              { name = "nvim_lsp"; }
              { name = "nvim_lsp_document_symbol"; }
              { name = "nvim_lsp_signature_help"; }
              { name = "buffer"; }
              { name = "codeium"; }
            ];
          };
        };
      };
    };
  };
}
