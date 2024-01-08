{ pkgs, internalLib, ... }:
{
  programs.neovim = {
    plugins = internalLib.createLuaPlugin {
      package = pkgs.vimPlugins.telescope-nvim;
      configs = (builtins.readFile ./telescope.lua);
      dependencies = [ pkgs.vimPlugins.telescope-ui-select-nvim ];
    };
    extraPackages = [ pkgs.ripgrep ];
  };
}
