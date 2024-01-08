{ pkgs, internalLib, ... }:
let
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p:
    with p; [
      c
      cpp
      rust
      lua
      python
      yaml
      xml
      vim
      vimdoc
      udev
      tsv
      toml
      strace
      ssh_config
      sql
      scss
      robot
      requirements
      regex
      pymanifest
      proto
      doxygen
      diff
      devicetree
      cuda
      css
      csv
      comment
      cmake
      c_sharp
      bibtex
      bash
      awk
      arduino
      dockerfile
      objdump
      nix
      mermaid
      markdown
      markdown_inline
      make
      linkerscript
      latex
      kdl
      json
      json5
      jsonc
      jq
      ini
      html
      gitignore
      gitcommit
      gitattributes
      git_rebase
      git_config
      fortran
      fish
      matlab
    ]);
in {
  programs.neovim.plugins = internalLib.createLuaPlugin {
    package = treesitter;
    configs = ''
      local config = require("nvim-treesitter.configs")
      config.setup({
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {enable = true },
        folding = {enable = true},
      })
      
    '';
  };
}
