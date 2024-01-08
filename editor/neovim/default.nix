{ config, pkgs, ... }: {

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraLuaConfig = (builtins.readFile ./init.lua);
    plugins = with pkgs.vimPlugins; [ rainbow-delimiters-nvim ];
  };

  imports = [
    ./colorscheme.nix
    ./neotree
    ./telescope
    ./which-key.nix
    ./treesitter.nix
    ./lsp
    ./lint
    ./completion
    ./lualine.nix
    ./dap
    ./comment.nix
  ];

}
