{ pkgs
, internalLib
, ...
}: {
  programs.neovim.plugins = internalLib.createLuaPlugin {
    package = pkgs.vimPlugins.git-conflict-nvim;
    configs = ''
      require('git-conflict').setup()
    '';
  };
}
