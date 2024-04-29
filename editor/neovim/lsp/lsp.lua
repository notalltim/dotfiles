local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require("lspconfig")

local which_key = require("which-key")

local global_options = {
    mode = "n", -- NORMAL mode
    prefix = nil,
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true -- use `nowait` when creating keymaps
}

local global_mapping = {
    ['<space>ld'] = {vim.diagnostic.open_float, "Open floating diagnostics"},
    ['[d'] = {vim.diagnostic.goto_prev, "Go to previous diagnostic"},
    [']d'] = {vim.diagnostic.goto_next, "Go to next diagnostic"},
    ['<space>lq'] = {
        vim.diagnostic.setloclist, "Add buffer diagnostics to location list"
    }
}

which_key.register(global_mapping, global_options)

local on_attach = function(client, _)
    if client == "clangd" then
        require("clangd_extensions.inlay_hints").setup_autocmd()
        require("clangd_extensions.inlay_hints").set_inlay_hints()
    end
end

lspconfig.clangd.setup({
    capabilities = capabilities,
    filetypes = {"c", "cpp", "objc", "objcpp", "cuda", "tpp"},
    on_attach = on_attach
})

-- tpp files are cpp files to!
vim.filetype.add({extension = {tpp = 'cpp'}})

-- lspconfig.rnix.setup({capabilities = capabilities})
lspconfig.lua_ls.setup({capabilities = capabilities})

lspconfig.pyright.setup({capabilities = capabilities})

lspconfig.neocmake.setup({capabilities = capabilities})

lspconfig.marksman.setup({capabilities = capabilities})

lspconfig.fortls.setup({capabilities = capabilities})

lspconfig.bashls.setup({capabilities = capabilities})

lspconfig.biome.setup({capabilities = capabilities})

lspconfig.ltex.setup({capabilities = capabilities})

lspconfig.lemminx.setup({capabilities = capabilities})

lspconfig.yamlls.setup({capabilities = capabilities})

lspconfig.docker_compose_language_service.setup({capabilities = capabilities})

lspconfig.dockerls.setup({capabilities = capabilities})

lspconfig.rust_analyzer.setup({capabilities = capabilities})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local options = {
            mode = "n", -- NORMAL mode
            prefix = nil,
            buffer = ev.buf, -- Global mappings. Specify a buffer number for buffer local mappings
            silent = true, -- use `silent` when creating keymaps
            noremap = true, -- use `noremap` when creating keymaps
            nowait = true -- use `nowait` when creating keymaps
        }
        local lsp = vim.lsp.buf;
        local mapping = {
            g = {
                d = {lsp.declaration, "Go to declaration"},
                D = {lsp.definition, "Go to definition"},
                i = {lsp.implementation, "Go to implementation"},
                r = {lsp.references, "Show references"}
            },
            ['K'] = {lsp.hover, "LSP hover action"},
            ["<space>l"] = {
                D = {lsp.type_definition, "Show type definition"},
                r = {lsp.rename, "Rename symbol"},
                a = {lsp.code_action, "Show code actions"},
                k = {lsp.signature_help, "Show function signature"}
            }
        }
        which_key.register(mapping, options)
    end
})
