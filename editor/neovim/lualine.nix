{ pkgs, internalLib, ... }: {

  programs.neovim.plugins =
    internalLib.createLuaPlugin
      {
        package = pkgs.vimPlugins.lualine-nvim;
        configs = ''
          require('lualine').setup {}
        '';
        dependencies = with pkgs.vimPlugins;[ nvim-web-devicons  ];
      };
}
