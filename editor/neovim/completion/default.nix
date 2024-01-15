{ pkgs
, internalLib
, ...
}: {
  programs.neovim = {
    plugins = internalLib.createLuaPlugin {
      package = pkgs.vimPlugins.nvim-cmp;
      dependencies = with pkgs.vimPlugins; [ cmp-nvim-lsp luasnip cmp_luasnip friendly-snippets ];
      configs = builtins.readFile ./completion.lua;
    };
    extraPackages = [ pkgs.lua51Packages.jsregexp ];
  };
}
