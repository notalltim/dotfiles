vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
-- Global undo files
vim.cmd("set undodir=~/.nvim/undodir")
vim.cmd("set undofile")
-- Share the system clipboard
vim.cmd("set clipboard+=unnamedplus")

vim.g.mapleader = " "

-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')

-- vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.cmdheight = 0

local opts = {
    mode = "n", -- NORMAL mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true -- use `nowait` when creating keymaps
}

local mappings = {
    w = {"<cmd>w<cr>", "Save"},
    q = {"<cmd>q<cr>", "Quit"},
    Q = {"<cmd>qall<cr>", "Quit all"},
    n = {"<cmd>new<cr>", "New file"},
    ["<leader>"] = {"<cmd>bn<cr>", "Cycle buffers"}
}

require("which-key").register(mappings, opts)
