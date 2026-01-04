{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkDefault mkIf;
  cfg = config.baseline.tools;
in
{
  imports = [
    ./direnv.nix
    ./eza.nix
    ./git.nix
    ./debugging.nix
  ];
  options = {
    baseline.tools.enable = mkEnableOption "Enable baseline set of tools";
  };
  config = mkIf cfg.enable {
    baseline.git.enable = mkDefault true;
    baseline.debugging.enable = mkDefault true;
    programs.bat.enable = true;

    home.packages = with pkgs; [
      clang-tools
      elfutils
      pkg-config
      gnumake
      cmake
      grpcui
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
      tbb
      compdb
      gnupg
      wget
      htop
      watchman
      # ykman
      yubikey-manager
      # fido2-token
      libfido2
      # GUI tools
      solaar
      openvpn3
      inkscape
      gimp
      vlc
      obsidian
    ];
  };
}
