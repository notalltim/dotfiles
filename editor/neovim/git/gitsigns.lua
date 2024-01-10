require("gitsigns").setup()

local opts = {
  mode = "n",       -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,     -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,    -- use `silent` when creating keymaps
  noremap = true,   -- use `noremap` when creating keymaps
  nowait = true     -- use `nowait` when creating keymaps
}

local git_icon =
    require 'nvim-web-devicons'.get_icon("git", "", { default = true })

local mapping = {
  g = {
    name = git_icon .. "Git",
    l = { "<cmd>lua require('gitsigns').blame_line()<cr>", "View Git blame" },
    L = {
      "<cmd>lua require('gitsigns').blame_line { full = true }<cr>",
      "Full git blame"
    },
    p = {
      "<cmd>lua require('gitsigns').preview_hunk() end",
      "Preview Git hunk"
    },
    h = { "<cmd>lua require('gitsigns').reset_hunk()<cr>", "Reset Git hunk" },
    r = {
      "<cmd>lua require('gitsigns').reset_buffer()<cr>",
      "Reset Git buffer"
    },
    s = { "<cmd>lua require('gitsigns').stage_hunk()<cr>", "Stage Git hunk" },
    S = {
      "<cmd>lua require('gitsigns').stage_buffer()<cr>",
      "Stage Git buffer"
    },
    u = {
      "<cmd>lua require('gitsigns').undo_stage_hunk()<cr>",
      "Unstage Git hunk"
    },
    d = { "<cmd>lua require('gitsigns').diffthis()<cr>", "View Git diff" },
    b = {
      "<cmd>lua require('telescope.builtin').git_branches()<cr>",
      "Git branches"
    },
    c = {
      "<cmd>lua require('telescope.builtin').git_commits()<cr>",
      "Git commits (repository)"
    },
    C = {
      "<cmd>lua require('telescope.builtin').git_bcommits()<cr>",
      "Git commits (current file)"
    },
    t = {
      "<cmd>lua require('telescope.builtin').git_status()<cr>",
      "Git status"
    }
  }
}

require("which-key").register(mapping, opts)
