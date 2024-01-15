local null_ls = require("null-ls")

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local on_attach = function(client, bufnr)
  if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
    return
  end
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function() vim.lsp.buf.format({ async = false }) end
    })
    -- vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --  group = augroup,
    --  buffer = bufnr,
    -- command = "undojoin | LspFormatting",
    -- })
  end
end

local opts = {
  mode = "n",       -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,     -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,    -- use `silent` when creating keymaps
  noremap = true,   -- use `noremap` when creating keymaps
  nowait = true     -- use `nowait` when creating keymaps
}

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, { desc = "Disable autoformat-on-save", bang = true })
vim.api.nvim_create_user_command("FormatEnable", function(args)
  if args.bang then
    vim.b.disable_autoformat = false
  else
    vim.g.disable_autoformat = false
    vim.b.disable_autoformat = false
  end
end, { desc = "Re-enable autoformat-on-save", bang = true })

require("which-key").register(mappings, opts)

null_ls.setup({
  sources = {
    null_ls.builtins.code_actions.gitrebase,
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.code_actions.proselint,
    null_ls.builtins.code_actions.ltrs,
    null_ls.builtins.code_actions.statix,

    -- null_ls.builtins.completion.spell,

    null_ls.builtins.diagnostics.commitlint,
    null_ls.builtins.diagnostics.cmake_lint,
    null_ls.builtins.diagnostics.deadnix, null_ls.builtins.diagnostics.fish,
    null_ls.builtins.diagnostics.mlint,
    null_ls.builtins.diagnostics.markdownlint_cli2,
    null_ls.builtins.diagnostics.protolint,
    null_ls.builtins.diagnostics.clang_check,
    null_ls.builtins.diagnostics.codespell,
    null_ls.builtins.diagnostics.pydocstyle,
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.proselint,
    null_ls.builtins.diagnostics.pycodestyle,

    null_ls.builtins.formatting.alejandra,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.clang_format,
    null_ls.builtins.formatting.cmake_format,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.formatting.lua_format,
    null_ls.builtins.formatting.mdformat,
    null_ls.builtins.formatting.rustfmt,
    null_ls.builtins.formatting.xmlformat,
    null_ls.builtins.formatting.xmllint,
    null_ls.builtins.formatting.yamlfmt,
    null_ls.builtins.formatting.codespell,
    null_ls.builtins.formatting.protolint,
    null_ls.builtins.formatting.autopep8, null_ls.builtins.hover.printenv
  },
  on_attach = on_attach
})
