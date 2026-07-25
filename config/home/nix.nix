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

  # When `nix.package` is null the binary is managed externally (Determinate Nix),
  # which is always a modern release: treat version gates as "latest".
  nixVerAtLeast =
    ver: config.nix.package == null || versionAtLeast (majorMinor config.nix.package.version) ver;
  nixVerAtMost =
    ver: config.nix.package != null && versionOlder (majorMinor config.nix.package.version) ver;
in
{
  options.baseline.nix = {
    enable = mkEnableOption "Enable my basic nix configuration";
    installPackage = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to install `config.nix.package` into the user profile. Disable this when
        the Nix binary is managed outside of home-manager (e.g. Determinate Nix, where the
        system daemon owns the only Nix and `nix.package` is `null`).
      '';
    };
    flakeSource = mkOption {
      type = nullOr pathInStore;
      default = null;
    };
  };

  config = mkIf cfg.enable {

    # Install the correct nix interpreter version
    home = {
      packages =
        # Only install the Nix binary when home-manager owns it. Determinate Nix
        # manages the binary/daemon itself and sets `nix.package = null`.
        (optional (cfg.installPackage && config.nix.package != null) config.nix.package)
        ++ (with pkgs; [
          nix-diff
          nix-du
          nil
          nixfmt
          nix-tree
          cachix
          qemu
          comma-with-db
          nix-melt
          nix-output-monitor
        ]);
      file."${config.xdg.cacheHome}/nix-index/files".source = pkgs.nix-index-database;

    };

    programs.nix-index = {
      enable = true;
      package = pkgs.nix-index-with-db;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    # My speific stuff for build time fetchers
    baseline.userModule = _: { extraGroups = optional config.nix.enableBuildTimeFetchers "root"; };

    nix = {
      gc = {
        automatic = true;
        dates = "monthly";
        persistent = true;
        options = "--delete-older-than 31d";
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
        # Min free space on disk before nix tries to garbage collect
        min-free = 5368709120; # 5GiB
        # Max to free in the above garbage collection
        max-free = 16106127360; # 15GiB
        # Supress error I do not care about
        warn-dirty = false;
        # More output from builds
        log-lines = 25;
        # If binary is not availible build it local
        fallback = true;
        # Keep the build time dependencies around
        keep-outputs = true;
        connect-timeout = 5;
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
