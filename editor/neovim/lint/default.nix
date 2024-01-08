{ pkgs
, internalLib
, ...
}: {
  programs.neovim = {
    plugins = internalLib.createLuaPlugin {
      package = pkgs.vimPlugins.none-ls-nvim;
      dependencies = with pkgs.vimPlugins; [ gitsigns-nvim ];
      configs = builtins.readFile ./lint.lua;
    };
    extraPackages = with pkgs; [
      checkmake
      markdownlint-cli2
      protolint
      alejandra
      black
      cmake-format
      isort
      luaformatter
      python3Packages.mdformat
      rustfmt
      libxml2
      xmlformat
      yamlfmt
      clang-tools
      python3Packages.autopep8
      python3Packages.pydocstyle
      proselint
      languagetool-rust
      hadolint
      statix
      python3Packages.pycodestyle
      codespell
      deadnix
    ];
  };
}
