{ pkgs, internalLib, ... }: {
  programs.neovim = {
    plugins = internalLib.createLuaPlugin {
      package = pkgs.vimPlugins.comment-nvim;
      configs = ''
      '';
    };
  };
}
