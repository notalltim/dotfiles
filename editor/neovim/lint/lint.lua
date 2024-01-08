local null_ls = require("null-ls")

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local on_attach = function(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
   -- vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
   -- vim.api.nvim_create_autocmd("BufWritePre", {
    --  group = augroup,
    --  buffer = bufnr,
     -- command = "undojoin | LspFormatting",
   -- })
  end
end
-- ["]g"] = { function() require("gitsigns").next_hunk() end, desc = "Next Git hunk" }
--   ["[g"] = { function() require("gitsigns").prev_hunk() end, desc = "Previous Git hunk" }

local opts = {
  mode = "n",     -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
}

local git_icon = require 'nvim-web-devicons'.get_icon("git", "", { default = true })
local telescope = "";


local mappings = {
  g = {
    name = git_icon .. "Git",
    l = { "<cmd>lua require('gitsigns').blame_line()<cr>", "View Git blame" },
    L = { "<cmd>lua require('gitsigns').blame_line { full = true }<cr>", "View full Git blame" },
    p = { "<cmd>lua require('gitsigns').preview_hunk() end", "Preview Git hunk" },
    h = { "<cmd>lua require('gitsigns').reset_hunk()<cr>", "Reset Git hunk" },
    r = { "<cmd>lua require('gitsigns').reset_buffer()<cr>", "Reset Git buffer" },
    s = { "<cmd>lua require('gitsigns').stage_hunk()<cr>", "Stage Git hunk" },
    S = { "<cmd>lua require('gitsigns').stage_buffer()<cr>", "Stage Git buffer" },
    u = { "<cmd>lua require('gitsigns').undo_stage_hunk()<cr>", "Unstage Git hunk" },
    d = { "<cmd>lua require('gitsigns').diffthis()<cr>", "View Git diff" },
    b = { "<cmd>lua require('telescope.builtin').git_branches()<cr>", "Git branches" },
    c = { "<cmd>lua require('telescope.builtin').git_commits()<cr>", "Git commits (repository)" },
    C = { "<cmd>lua require('telescope.builtin').git_bcommits()<cr>", "Git commits (current file)" },
    t = { "<cmd>lua require('telescope.builtin').git_status()<cr>", "Git status" },
  },

  f = {
    name = telescope .. "Search",
    b = { "<cmd>lua require('telescope.builtin').buffers()<cr>", "Find buffers" },
    c = { "<cmd>lua require('telescope.builtin').grep_string()<cr>", "Find word under cursor" },
    C = { "<cmd>lua require('telescope.builtin').commands()<cr>", "Find commands" },
    f = { "<cmd>lua require('telescope.builtin').find_files()<cr>", "Find files" },
    F = { "<cmd>lua require('telescope.builtin').find_files  { hidden = true, no_ignore = true }<cr>", "Find all files" },
  }
}

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
    null_ls.builtins.diagnostics.deadnix,
    null_ls.builtins.diagnostics.fish,
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
    null_ls.builtins.formatting.autopep8,

    null_ls.builtins.hover.printenv,
  },
  on_attach = on_attach
})
