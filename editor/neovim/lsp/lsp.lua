local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require("lspconfig")

local on_attach = function(client, buffer)
  require("clangd_extensions.inlay_hints").setup_autocmd()
  require("clangd_extensions.inlay_hints").set_inlay_hints()
end

lspconfig.clangd.setup({
  capabilities = capabilities,
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "tpp" },
  on_attach = on_attach
})

lspconfig.rnix.setup({
  capabilities = capabilities
})
lspconfig.lua_ls.setup({
  capabilities = capabilities
})

lspconfig.pyright.setup({
  capabilities = capabilities
})

lspconfig.neocmake.setup({
  capabilities = capabilities
})

lspconfig.marksman.setup({
  capabilities = capabilities
})

lspconfig.fortls.setup({
  capabilities = capabilities
})

lspconfig.bashls.setup({
  capabilities = capabilities
})

lspconfig.biome.setup({
  capabilities = capabilities
})

lspconfig.ltex.setup({
  capabilities = capabilities
})

lspconfig.lemminx.setup({
  capabilities = capabilities
})

lspconfig.yamlls.setup({
  capabilities = capabilities
})

lspconfig.docker_compose_language_service.setup({
  capabilities = capabilities
})

lspconfig.dockerls.setup({
  capabilities = capabilities
})

lspconfig.rust_analyzer.setup({
  capabilities = capabilities
})
