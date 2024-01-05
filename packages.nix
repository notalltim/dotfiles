{ pkgs }:

let
  nixTools = with pkgs; [
    cachix
    lorri
    # nixseparatedebuginfod
    # nix-heuristic-gc
    # iragenix
  ];
  developerTools = with pkgs; [
    gdb
    python3
    git
    clang-tools_17
    pkg-config
    gnumake
    cmake
    cmake-language-server
    # gersemi
    #rust
    # nix
    nil
    alejandra
    nixpkgs-fmt
    nixfmt
    rnix-lsp
    # rust
    rustc
    rustfmt
    cargo
    cargo-info
    cargo-audit
    cargo-license
    cargo-feature
    cargo-tarpaulin
    rust-analyzer
    bacon
    clippy


    # markdown
    marksman

    # lua
    lua-language-server

    direnv

    # Tools
    # wireshark needs a capability set on the dump cap file 

    nixgl.nixVulkanIntel
    nixgl.nixGLIntel
    # nixgl.auto.nixVulkanNvidia
    # nixgl.auto.nixGLNvidia
    # nixgl.auto.nixGLNvidiaBumblebee

  ];

  unixTools = with pkgs; [
    gnupg
  ];
in
nixTools ++ developerTools ++ unixTools
