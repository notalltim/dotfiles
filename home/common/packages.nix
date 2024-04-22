{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  nixTools = with pkgs; [
    cachix
    lorri
  ];
  developerTools = with pkgs; [
    gdb
    python3Full
    git
    git-filter-repo
    lazygit
    clang-tools_17
    elfutils
    valgrind
    pkg-config
    gnumake
    cmake
    grpcui
    # nix
    nil
    # rust
    (fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
      "rust-analyzer"
      "miri"
      "rust-docs"
    ])
    cargo-info
    cargo-audit
    cargo-license
    cargo-feature
    cargo-tarpaulin
    bacon

    # kitty
    nixgl.nixVulkanIntel
    nixgl.nixGLIntel
    tbb
    compdb
  ];

  unixTools = with pkgs; [gnupg wget htop rs-git-fsmonitor watchman];
  guiTools = with pkgs; [solaar openvpn3 spotify inkscape gimp vlc obsidian];

  cfg = config.baseline.packages;
in {
  options = {
    baseline.packages.enable = mkEnableOption "Enable the base set of packages";
  };

  config = mkIf cfg.enable {
    home.packages =
      nixTools
      ++ developerTools
      ++ unixTools
      ++ guiTools;
  };
}
