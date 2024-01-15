{ pkgs
, internalLib
, ...
}: {
  programs.neovim.plugins = internalLib.createLuaPlugin {
    package = pkgs.vimPlugins.gitsigns-nvim.overrideAttrs (_: {
      src = pkgs.fetchFromGitHub {
        owner = "lewis6991";
        repo = "gitsigns.nvim";
        rev = "4aaacbf5e5e2218fd05eb75703fe9e0f85335803";
        hash = "sha256-y8aoZa5UJGP0rgvYPL6NMD3IjbZnnGweZcTBIR5bAxU=";
      };
      patches = [ ./remove-hunks-assert.patch ];
    });
    configs = builtins.readFile ./gitsigns.lua;
  };
}
