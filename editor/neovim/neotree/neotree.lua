local opts = {
  mode = "n",     -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
}

local folder = "";

local mappings = {
  e = { "<cmd>Neotree toggle<cr>", folder .. "Toggle Explorer" },
  o = { function() if vim.bo.filetype == 'neo-tree' then vim.cmd.wincmd 'p' else vim.cmd.Neotree 'focus' end end, "Toggle focus" },
}
require("which-key").register(mappings, opts)
