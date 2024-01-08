{ pkgs, internalLib, ... }: {
  programs.neovim = {
    plugins = internalLib.createLuaPlugin {
      package = pkgs.vimPlugins.nvim-lspconfig;
      dependencies = with pkgs.vimPlugins; [ clangd_extensions-nvim ];
      configs = (builtins.readFile ./lsp.lua);
    };
    extraPackages = with pkgs; [
      clang-tools
      rnix-lsp
      nodePackages.pyright
      rust-analyzer
      marksman
      yaml-language-server
      biome
      docker-compose-language-service
      dockerfile-language-server-nodejs
      neocmakelsp
      nodePackages.bash-language-server
      fortls
      ltex-ls
      lemminx
    ];
  };
}
