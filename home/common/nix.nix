{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib) mkIf;
  cfg = config.baseline.nix;
in
{
  options.baseline.nix = {
    enable = mkEnableOption "nix install configuration";
    package = mkPackageOption pkgs "nix" { };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    nix = {
      package = cfg.package;

      registry.nixpkgs = {
        exact = true;
        from = {
          type = "indirect";
          id = "nixpkgs";
        };
        to = {
          type = "tarball";
          url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1.0.tar.gz";
        };
      };

      settings = {
        auto-optimise-store = true;
        always-allow-substitutes = true;
        bash-prompt-prefix = "(nix:$name)\\040";
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        extra-nix-path = [ "nixpkgs=flake:nixpkgs" ];
        upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
      };
    };
  };
}
