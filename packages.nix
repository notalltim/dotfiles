{
  pkgs,
  internalLib,
  isHome ? false,
}: let
  nixTools = with pkgs; [
    cachix
    lorri
    # nixseparatedebuginfod
    # nix-heuristic-gc
    # iragenix
  ];
  developerTools = with pkgs; [
    (gdb.overrideAttrs (_: rec {
      version = "14.1";
      src = pkgs.fetchurl {
        url = "mirror://gnu/gdb/gdb-${version}.tar.xz";
        hash = "sha256-1m31EnYUNFH8v/RkzIcj1o8enfRaai1WNaVOcWQ+24A=";
      };
    }))
    python3
    git
    git-filter-repo
    clang-tools_17
    elfutils
    valgrind
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
    # kitty
    tbb
    compdb
  ];

  unixTools = with pkgs; [gnupg wget htop rs-git-fsmonitor watchman];

  guiTools = with pkgs; [solaar openvpn3 spotify inkscape gimp vlc obsidian];

  homeTools = with pkgs; [
    (internalLib.writeIntelGLWrapper kicad)
    (internalLib.writeIntelGLWrapper freecad)
    discord
    radeontop
    bitwarden
    # musescore
    audacity
    mprime
    openrgb-with-all-plugins
  ];
  workTools = with pkgs; [gnome.dconf-editor onedrive signal-desktop nixgl.auto.nixGLDefault winePackages.stable];
in
  nixTools
  ++ developerTools
  ++ unixTools
  ++ guiTools
  ++ (
    if isHome
    then homeTools
    else workTools
  )
