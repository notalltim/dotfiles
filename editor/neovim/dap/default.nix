{
  pkgs,
  internalLib,
  ...
}: {
  programs.neovim = {
    plugins = internalLib.createLuaPlugin {
      package = pkgs.vimPlugins.nvim-dap;
      dependencies = with pkgs.vimPlugins; [nvim-dap-ui nvim-dap-python];
      configs =
        ''
          require('dap-python').setup("${pkgs.python3}/bin/python3")
        ''
        + (builtins.readFile ./debugging.lua);
    };
    extraPackages = with pkgs; [
      (pkgs.python3Packages.debugpy.overrideAttrs
        (oldAttrs: {
          pytestCheckPhase = "true";
        }))
    ];
  };
}
