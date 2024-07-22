{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  cfg = config.baseline.nixvim.lsp;
in {
  options = {
    baseline.nixvim.lsp = {
      enable = mkEnableOption "Enable baseline LSP configuiration";
    };
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      # HACK: This is needed because the userCommand module does not handle lua for user commands
      extraConfigLuaPre = ''
        vim.api.nvim_create_user_command("AutoFormatDisable", function(args)
            if args.bang then
                vim.b.disable_autoformat = false
            else
                vim.g.disable_autoformat = false
                vim.b.disable_autoformat = false
            end
        end, {desc = "Re-enable autoformat-on-save", bang = true})

        vim.api.nvim_create_user_command("AutoFormatEnable", function(args)
            if args.bang then
                -- FormatDisable! will disable formatting just for this buffer
                vim.b.disable_autoformat = true
            else
                vim.g.disable_autoformat = true
            end
        end, {desc = "Disable autoformat-on-save", bang = true})
      '';
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
      plugins.telescope.keymaps = {
        "<leader>ls" = {
          action = "lsp_document_symbols";
          options = {
            desc = "Search LSP symbols";
          };
        };
      };

      # Add to dictionary ltex
      plugins.ltex-extra.enable = true;

      # Setup linters and formatters
      autoGroups.LspFormatting = {};

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
            codespell.enable = true;
            hadolint.enable = true;
            proselint.enable = true;
            mypy.enable = true;
          };

          formatting = {
            alejandra.enable = true;
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
            yamlfmt.enable = true;
            codespell.enable = true;
            protolint.enable = true;
          };
          hover.printenv.enable = true;
        };
        settings.on_attach = ''
          function(client, bufnr)
              require('lsp-format').on_attach(client, bufnr)
              if client.supports_method("textDocument/formatting") then
                  vim.api.nvim_buf_create_user_command(bufnr, "LspFormatting", function()
                    vim.lsp.buf.format({
                        filter = function(client)
                            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                                return false
                            end
                        end,
                        bufnr = bufnr
                    })
                  end, {})
                  vim.api.nvim_clear_autocmds({group = augroup, buffer = bufnr})
                  vim.api.nvim_create_autocmd("BufWritePre", {
                      group = augroup,
                      buffer = bufnr,
                      command = "LspFormatting"
                  })
              end
          end
        '';
      };

      plugins.which-key.registrations = {
        "<leader>l" = "🌡LSP";
        K = "LSP hover action";
        "<leader>le" = "Go to references";
        "<leader>ld" = "Go to declaration";
        "<leader>lD" = "Go to definition";
        "<leader>li" = "Go to implementation";
        "<leader>lt" = "Go to type definition";
        "<leader>la" = "List code actions";
        "<leader>lf" = "Show function signature";
        "<leader>lr" = "Rename symbol";
        "<leader>lq" = "Show diagnostics";
        "<space>ll" = "Show floating diagnostics";
      };

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
            filetypes = ["c" "cpp" "objc" "objcpp" "cuda" "tpp"];
            onAttach.function = ''
              if client == "clangd" then
                  require("clangd_extensions.inlay_hints").setup_autocmd()
                  require("clangd_extensions.inlay_hints").set_inlay_hints()
              end
            '';
          };
          lua-ls.enable = true;
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
            ];
          };
          lemminx.enable = true;
          yamlls.enable = true;
          dockerls.enable = true;
          docker-compose-language-service.enable = true;
          rust-analyzer = {
            enable = true;
            cargoPackage = pkgs.cargo;
            rustcPackage = pkgs.rustc;
            installRustc = false;
            installCargo = false;
          };
          nil-ls.enable = true;
          texlab.enable = true;
        };
      };
    };
  };
}
