{
  pkgs,
  internalLib,
  ...
}: {
  programs.neovim.plugins = internalLib.createLuaPlugin {
    package = pkgs.vimPlugins.gitsigns-nvim;
    configs = builtins.readFile ./gitsigns.lua;
  };
}
