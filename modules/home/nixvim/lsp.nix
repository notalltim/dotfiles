{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  cfg = config.baseline.nixvim.lsp;
  nixvim = config.programs.nixvim;
in
{
  options = {
    baseline.nixvim.lsp = {
      enable = mkEnableOption "Enable baseline LSP configuiration";
    };
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      # Add inlays for clangd
      plugins.clangd-extensions = {
        enable = true;
        enableOffsetEncodingWorkaround = true;
      };

      # Symbols in completion
      plugins.lspkind = {
        enable = true;
        cmp.enable = true;
      };

      # Enable telescope key map if telescope is enabled
      plugins.telescope.keymaps = mkIf nixvim.plugins.telescope.enable {
        "<leader>ls" = {
          action = "lsp_document_symbols";
          options = {
            desc = "Search LSP symbols";
          };
        };
      };

      # Add to dictionary ltex
      plugins.ltex-extra.enable = true;

      plugins.lsp-format.enable = true;
      plugins.none-ls = {
        enable = true;
        enableLspFormat = false;
        sources = {
          code_actions = {
            gitrebase.enable = true;
            gitsigns.enable = true;
            proselint.enable = true;
            statix.enable = true;
          };

          diagnostics = {
            selene.enable = true;
            gitlint.enable = true;
            cmake_lint.enable = true;
            deadnix.enable = true;
            fish.enable = true;
            # Installed with matlab
            mlint = {
              enable = true;
              package = null;
            };
            markdownlint_cli2.enable = true;
            protolint.enable = true;
            hadolint.enable = true;
            proselint.enable = true;
            mypy.enable = true;
          };

          formatting = {
            treefmt.enable = true;
            biome.enable = true;
            nixfmt = {
              enable = true;
              package = pkgs.nixfmt-rfc-style;
            };
            black.enable = true;
            clang_format = {
              enable = true;
              settings = "{disabled_filetypes = {\"proto\"}}";
            };
            cmake_format.enable = true;
            isort.enable = true;
            stylua.enable = true;
            mdformat.enable = true;
            tidy.enable = true;
            yamlfmt = {
              enable = true;
              settings = {
                formatter.trim_trailing_whitespace = true;
              };
            };
          };
          hover.printenv.enable = true;
        };
        settings.on_attach = ''
          function(client, bufnr)
              require('lsp-format').on_attach(client, bufnr)
          end
        '';
      };

      plugins.which-key.settings.spec = mkIf nixvim.plugins.which-key.enable [
        {
          __unkeyed-1 = "<leader>l";
          desc = "LSP";
          icon = "🌡";
        }
        {
          __unkeyed-1 = "K";
          desc = "LSP hover action";
        }
        {
          __unkeyed-1 = "<leader>le";
          desc = "Go to references";
        }
        {
          __unkeyed-1 = "<leader>ld";
          desc = "Go to declaration";
        }
        {
          __unkeyed-1 = "<leader>lD";
          desc = "Go to definition";
        }
        {
          __unkeyed-1 = "<leader>li";
          desc = "Go to implementation";
        }
        {
          __unkeyed-1 = "<leader>lt";
          desc = "Go to type definition";
        }
        {
          __unkeyed-1 = "<leader>la";
          desc = "List code actions";
        }
        {
          __unkeyed-1 = "<leader>lf";
          desc = "Show function signature";
        }
        {
          __unkeyed-1 = "<leader>lr";
          desc = "Rename symbol";
        }
        {
          __unkeyed-1 = "<leader>lq";
          desc = "Show diagnostics";
        }
        {
          __unkeyed-1 = "<space>ll";
          desc = "Show floating diagnostics";
        }
      ];

      plugins.lsp = {
        enable = true;

        keymaps = {
          diagnostic = {
            "[d" = "goto_prev";
            "d]" = "goto_next";
            "<leader>lq" = "setloclist";
            "<space>ll" = "open_float";
          };

          lspBuf = {
            K = "hover";
            "<leader>le" = "references";
            "<leader>ld" = "declaration";
            "<leader>lD" = "definition";
            "<leader>li" = "implementation";
            "<leader>lt" = "type_definition";
            "<leader>la" = "code_action";
            "<leader>lf" = "signature_help";
            "<leader>lr" = "rename";
          };
        };

        servers = {
          clangd = {
            enable = true;
            # Add tpp files to the lsp list and remove proto
            filetypes = [
              "c"
              "cpp"
              "objc"
              "objcpp"
              "cuda"
              "tpp"
            ];
            onAttach.function = ''
              if client == "clangd" then
                  require("clangd_extensions.inlay_hints").setup_autocmd()
                  require("clangd_extensions.inlay_hints").set_inlay_hints()
              end
            '';
          };
          lua_ls.enable = true;
          pyright.enable = true;
          # TODO: verify that I dont need to add neo cmake
          cmake.enable = true;
          marksman.enable = true;
          bashls.enable = true;
          fortls.enable = true;
          biome.enable = true;
          # Add the cpp for comment grammar/spelling
          ltex = {
            enable = true;
            filetypes = [
              "bib"
              "gitcommit"
              "markdown"
              "org"
              "plaintex"
              "rst"
              "rnoweb"
              "tex"
              "pandoc"
              "quatro"
              "rmd"
              "context"
              "html"
              "xhtml"
              "mail"
              "text"
              "rust"
            ];
            settings.enabled = [
              "bibtex"
              "context"
              "context.tex"
              "html"
              "latex"
              "markdown"
              "org"
              "restructuredtext"
              "rsweave"
              "c"
              "cpp"
              "objc"
              "objcpp"
              "cuda"
              "tpp"
              "rust"
            ];
          };
          lemminx.enable = true;
          yamlls.enable = true;
          dockerls.enable = true;
          docker_compose_language_service.enable = true;
          rust_analyzer = {
            enable = true;
            cargoPackage = pkgs.cargo;
            rustcPackage = pkgs.rustc;
            installRustc = false;
            installCargo = false;
          };
          nil_ls.enable = true;
          texlab.enable = true;
        };
      };
    };
  };
}
