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
    versionOlder
    mkForce
    mkOption
    optional
    ;
  inherit (lib.versions) majorMinor;
  inherit (lib.types) path nullOr;
  cfg = config.baseline.nix;
  nixVerAtLeast = versionAtLeast (majorMinor cfg.package.version);
  nixVerAtMost = versionOlder (majorMinor cfg.package.version);
in
{
  options.baseline.nix = {
    enable = mkEnableOption "nix install configuration";
    package = mkPackageOption pkgs "nix" { };
    accessTokensPath = mkOption {
      type = nullOr path;
      default = null;
    };
    netrcPath = mkOption {
      type = nullOr path;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    systemd.user.sessionVariables.NIX_PATH = mkForce "";
    age.secrets = {
      nix-access-tokens = mkIf (cfg.accessTokensPath != null) {
        rekeyFile = cfg.accessTokensPath;
        path = "${config.xdg.cacheHome}/nix/access-tokens.conf";
      };
      netrc = mkIf (cfg.netrcPath != null) {
        rekeyFile = cfg.netrcPath;
        path = "${config.xdg.configHome}/nix/netrc";
      };
    };
    nix = {
      keepOldNixPath = false;
      package = cfg.package;

      # Make nixpkgs# use the nixpkgs used to eval
      registry.nixpkgs = {
        exact = true;
        flake = self;
      };

      extraOptions = mkIf (cfg.accessTokensPath != null) ''
        !include ${config.age.secrets.nix-access-tokens.path};
      '';

      settings =
        {
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ] ++ optional (nixVerAtMost "2.19") "repl-flakes";
          # Make nix-shell work see default.nix at the root
          nix-path = [ "nixpkgs=${self.outPath}" ];
          netrc-file = mkIf (cfg.netrcPath != null) config.age.secrets.netrc.path;
          substituters = [ "https://cache.nixos.org" ];
          trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
        }
        // optionalAttrs (nixVerAtLeast "2.20") {
          upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
          always-allow-substitutes = true;
        };
    };
  };
}
