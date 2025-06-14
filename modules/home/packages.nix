{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  inherit (builtins) hasAttr;
  nixTools = with pkgs; [
    cachix
    qemu
    comma-with-db
    # lorri
  ];
  developerTools = with pkgs; [
    git
    git-filter-repo
    lazygit
    clang-tools
    elfutils
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
    cargo-audit
    cargo-license
    cargo-feature
    cargo-tarpaulin
    bacon
    nix-tree
    tbb
    compdb
    nixfmt-rfc-style
  ];

  unixTools = with pkgs; [
    gnupg
    wget
    htop
    rs-git-fsmonitor
    watchman
    # ykman
    yubikey-manager
    # fido2-token
    libfido2
  ];
  guiTools = with pkgs; [
    solaar
    openvpn3
    # spotify
    inkscape
    gimp
    vlc
    obsidian
  ];

  cfg = config.baseline.packages;
in
{
  options = {
    baseline.packages.enable = mkEnableOption "Enable the base set of packages";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasAttr "fenix" pkgs;
        message = ''
          fenix is missing you need to include either the `overlays.fenix` 
          or `overlays.default` notalltim's flake in the `nixpkgs.overlays` option'';
      }
    ];
    home = {
      packages = nixTools ++ developerTools ++ unixTools ++ guiTools;
      file."${config.xdg.cacheHome}/nix-index/files".source = pkgs.nix-index-database;
    };
    programs.nix-index = {
      enable = true;
      package = pkgs.nix-index-with-db;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };
  };
}
