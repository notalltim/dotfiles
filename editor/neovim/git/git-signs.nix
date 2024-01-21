{
  pkgs,
  internalLib,
  ...
}: {
  programs.neovim.plugins = internalLib.createLuaPlugin {
    package = pkgs.vimPlugins.gitsigns-nvim.overrideAttrs (_: {
      src = pkgs.fetchFromGitHub {
        owner = "lewis6991";
        repo = "gitsigns.nvim";
        rev = "v0.7";
        hash = "sha256-cVs6thVq70ggQTvK/wEi377OgXqoaX3ulnyr+z6s0iA=";
      };
      # patches = [ ./remove-hunks-assert.patch ];
    });
    configs = builtins.readFile ./gitsigns.lua;
  };
}
