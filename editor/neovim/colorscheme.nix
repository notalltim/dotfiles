{ pkgs, internalLib, ... }:

let
  nightfox = internalLib.createLuaPlugin {
    package = pkgs.vimPlugins.nightfox-nvim;
    configs = ''
       vim.cmd("colorscheme nightfox")
    '';
  };
in
{
  programs.neovim.plugins = nightfox;
}
