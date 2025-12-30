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
    mkOption
    types
    ;
  inherit (types) pathInStore nullOr;
  inherit (lib.versions) majorMinor;

  cfg = config.baseline.nix;

  nixVerAtLeast = versionAtLeast (majorMinor config.nix.package.version);
  nixVerAtMost = versionOlder (majorMinor config.nix.package.version);
in
{
  options.baseline.nix = {
    enable = mkEnableOption "Enable my basic nix configuration";
    flakeSource = mkOption {
      type = nullOr pathInStore;
      default = null;
    };
  };

  config = mkIf cfg.enable {

    # Install the correct nix interpreter version
    home.packages = with pkgs; [
      config.nix.package
      nix-diff
      nix-du
    ];

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
      registry.nixpkgs = mkIf (cfg.flakeSource != null) {
        exact = true;
        flake = cfg.flakeSource;
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
        nix-path = mkIf (cfg.flakeSource != null) [ "nixpkgs=${cfg.flakeSource}" ];
      }
      // optionalAttrs (nixVerAtLeast "2.20") {
        upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
        always-allow-substitutes = true;
      };
    };
  };
}
