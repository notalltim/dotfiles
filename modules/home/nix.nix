{
  config,
  lib,
  pkgs,
  baselineLib,
  options,
  ...
}:
let
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib)
    mkIf
    optionalAttrs
    versionAtLeast
    versionOlder
    mkOption
    mkDefault
    optional
    escapeShellArg
    ;
  inherit (lib.versions) majorMinor;
  inherit (lib.types)
    path
    nullOr
    str
    listOf
    submodule
    ;
  inherit (lib.fileset) toSource unions;
  inherit (baselineLib) mkPathReproducible;

  cfg = config.baseline.nix;
  nixVerAtLeast = versionAtLeast (majorMinor cfg.package.version);
  nixVerAtMost = versionOlder (majorMinor cfg.package.version);
  # Make the build more reproducible perhaps there is a better way
  filterdSource = toSource {
    root = ../..;
    fileset = unions [
      ../../default.nix
      ../../flake.nix
      ../../flake.lock
      ../../overlays
      ../../pkgs
      ../../modules/default.nix
      ../../hosts/default.nix
      ../../users/default.nix
    ];
  };
in
{
  options.baseline.nix = {
    enable = mkEnableOption "nix install configuration";
    package = mkPackageOption pkgs "nix" { };
    nixDaemoGroup = mkOption {
      type = nullOr str;
      default = null;
    };
    accessTokensPath = mkOption {
      type = nullOr path;
      apply = path: if path != null then mkPathReproducible path else null;
      default = null;
    };
    netrcPath = mkOption {
      type = nullOr path;
      # apply = path: if path != null then mkPathReproducible path else null;
      default = null;
    };
    netrc = mkOption {
      type = listOf (submodule {
        options = {
          url = mkOption {
            type = str;
          };
          user = mkOption {
            type = str;
            default = config.home.username;
          };
          pubkey = mkOption {
            type = nullOr str;
            default = null;
          };
          secret = mkOption {
            type = options.age.secrets.nestedTypes.elemType;
          };
        };
      });
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    age.secrets = {
      nix-access-tokens = mkIf (cfg.accessTokensPath != null) {
        rekeyFile = cfg.accessTokensPath;
        path = "${config.xdg.cacheHome}/nix/access-tokens.conf";
      };
    };

    # Support build time fetchers
    home.activation = mkIf (cfg.nixDaemoGroup != null) {
      chownHome = (
        builtins.concatStringsSep "\n" (
          builtins.map (path: "chown ${config.home.username}:${cfg.nixDaemoGroup} ${path}") [
            "${config.home.homeDirectory}"
            "${config.home.homeDirectory}/.config"
            "${config.home.homeDirectory}/.config/nix "
          ]
        )
      );
    };

    age.secrets.netrc = mkIf (cfg.netrc != [ ]) {
      rekeyFile = cfg.netrcPath;
      path = "${config.xdg.configHome}/nix/netrc";
      # Support build time fetchers
      symlink = false;
      mode = "0644";
      group = cfg.nixDaemoGroup;
      generator = {
        dependencies = (builtins.map (val: val.secret) cfg.netrc);
        script =
          { ... }:
          builtins.concatStringsSep "\n" (
            builtins.map (
              key:
              "printf 'machine ${key.url} login ${key.user} password $(decrypt ${escapeShellArg key.secret.file})'"
            ) cfg.netrc
          );
      };
    };

    nix = {
      keepOldNixPath = false;
      package = mkDefault cfg.package;

      # Make nixpkgs# use the nixpkgs used to eval
      registry.nixpkgs = {
        exact = true;
        flake = filterdSource;
      };

      extraOptions = mkIf (cfg.accessTokensPath != null) ''
        !include ${config.age.secrets.nix-access-tokens.path}
      '';

      settings =
        let
          filterdCaches = (builtins.filter (val: val.pubkey != null) cfg.netrc);
        in
        {
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ]
          ++ optional (nixVerAtMost "2.19") "repl-flake";
          # Make nix-shell work see default.nix at the root
          nix-path = [ "nixpkgs=${filterdSource}" ];
          netrc-file = mkIf (cfg.netrc != [ ]) config.age.secrets.netrc.path;
          substituters = [
            "https://cache.nixos.org"
          ]
          ++ (builtins.map (val: "https://${val.url}") filterdCaches);
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ]
          ++ (builtins.map (val: val.pubkey) filterdCaches);
        }
        // optionalAttrs (nixVerAtLeast "2.20") {
          upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
          always-allow-substitutes = true;
        };
    };
  };
}
