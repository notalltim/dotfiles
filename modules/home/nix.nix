{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib)
    mkIf
    optionalAttrs
    versionAtLeast
    mkForce
    ;
  inherit (lib.versions) majorMinor;
  cfg = config.baseline.nix;
in
{
  options.baseline.nix = {
    enable = mkEnableOption "nix install configuration";
    package = mkPackageOption pkgs "nix" { };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    systemd.user.sessionVariables.NIX_PATH = mkForce "";
    nix = {
      keepOldNixPath = false;
      package = cfg.package;

      # Make nixpkgs# use the nixpkgs used to eval
      registry.nixpkgs = {
        exact = true;
        flake = self;
      };

      settings =
        {
          auto-optimise-store = true;
          bash-prompt-prefix = "(nix:$name)\\040";
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          # Make nix-shell work see default.nix at the root
          nix-path = [ "nixpkgs=${self.outPath}" ];
        }
        // optionalAttrs (versionAtLeast (majorMinor cfg.package.version) "2.20") {
          upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
          always-allow-substitutes = true;
        };
    };
  };
}
