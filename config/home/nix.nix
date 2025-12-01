{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib)
    mkIf
    optionalAttrs
    versionAtLeast
    versionOlder
    mkDefault
    optional
    ;
  inherit (lib.versions) majorMinor;

  inherit (lib.fileset) toSource unions;

  cfg = config.baseline.nix;
  nixVerAtLeast = versionAtLeast (majorMinor config.nix.package.version);
  nixVerAtMost = versionOlder (majorMinor config.nix.package.version);
  # Make the build more reproducible perhaps there is a better way
  filterdSource = toSource {
    root = ../..;
    fileset = unions [
      ../../default.nix
      ../../flake.nix
      ../../flake.lock
      ../../overlays
      ../../pkgs
      ../../config/default.nix
      ../../modules/default.nix
      ../../hosts/default.nix
      ../../users/default.nix
    ];
  };
in
{
  options.baseline.nix = {
    enable = mkEnableOption "Enable my basic nix configuration";
  };

  config = mkIf cfg.enable {

    # Install the correct nix interpreter version
    home.packages = [ config.nix.package ];

    # My speific stuff for build time fetchers
    baseline.userModule = _: { extraGroups = optional config.nix.enableBuildTimeFetchers "root"; };

    nix = {
      gc = {
        automatic = true;
        frequency = "weekly";
        persistent = true;
        options = "--delete-older-than 28d";
      };

      # Default to the current nix
      package = mkDefault pkgs.nix;

      # Make nixpkgs# use the nixpkgs used to eval
      registry.nixpkgs = {
        exact = true;
        flake = filterdSource;
      };
      keepOldNixPath = false;

      settings = {
        # automatic hard linking
        auto-optimise-store = true;
        # We use flakes
        experimental-features = [
          "nix-command"
          "flakes"
        ]
        ++ optional (nixVerAtMost "2.19") "repl-flake";
        # Make nix-shell work see default.nix at the root
        nix-path = [ "nixpkgs=${filterdSource}" ];
      }
      // optionalAttrs (nixVerAtLeast "2.20") {
        upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
        always-allow-substitutes = true;
      };
    };
  };
}
