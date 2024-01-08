require("telescope").setup({
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({}),
    },
  },
})

require("telescope").load_extension("ui-select")

local opts = {
  mode = "n",     -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
}
local telescope = "";
local file = "";

local mappings = {
  f = {
    name = file .. "File Search",
    C = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
    f = { "<cmd>lua require('telescope.builtin').find_files()<cr>", "Find files" },
    t = { "<cmd>Telescope live_grep <cr>", "Find Text Pattern In All Files" },
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
    c = { "<cmd>lua require('telescope.builtin').grep_string()<cr>", "Find word under cursor" },
    F = { "<cmd>lua require('telescope.builtin').find_files  { hidden = true, no_ignore = true }<cr>", "Find all files" },
  },
  s = {
    name = telescope .. "Search",
    h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
    m = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
    r = { "<cmd>Telescope registers<cr>", "Registers" },
    k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
    c = { "<cmd>Telescope commands<cr>", "Commands" },
  },
  g = {
    b = { "<cmd>lua require('telescope.builtin').git_branches()<cr>", "Git branches" },
    c = { "<cmd>lua require('telescope.builtin').git_commits()<cr>", "Git commits (repository)" },
    C = { "<cmd>lua require('telescope.builtin').git_bcommits()<cr>", "Git commits (current file)" },
    t = { "<cmd>lua require('telescope.builtin').git_status()<cr>", "Git status" },
  },
  l = {
    s = { "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", "Search symbols"},
  }
}
require("which-key").register(mappings, opts)
