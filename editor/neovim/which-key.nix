{pkgs, internalLib, ...}: {
  programs.neovim.plugins = internalLib.createLuaPlugin {
    package = pkgs.vimPlugins.which-key-nvim;
  };
}