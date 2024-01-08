{ pkgs, internalLib, ... }: {
  programs.neovim = {
    plugins = internalLib.createLuaPlugin {
      package = pkgs.vimPlugins.nvim-cmp;
      dependencies = with pkgs.vimPlugins; [ cmp-nvim-lsp  ];
      configs = (builtins.readFile ./completion.lua);
    };
  };
}
