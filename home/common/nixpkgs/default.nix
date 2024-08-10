{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  cfg = config.baseline.nixpkgs;
in {
  options.baseline.nixpkgs = {
    enable = mkEnableOption "nixpkgs config managments";
  };

  config = mkIf cfg.enable {
    nixpkgs.config = import ./nixpkgs-config.nix;
    xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;
  };
}
