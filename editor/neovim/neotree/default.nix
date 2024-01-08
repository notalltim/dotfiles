{ pkgs, internalLib, ... }: {
  programs.neovim.plugins = internalLib.createLuaPlugin {
    package = pkgs.vimPlugins.neo-tree-nvim;
    configs = (builtins.readFile ./neotree.lua);
    dependencies = [ pkgs.vimPlugins.nvim-web-devicons ];
  };
}
