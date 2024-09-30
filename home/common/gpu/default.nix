{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) str nullOr;
  inherit (lib.lists) optional;
  inherit (builtins) hasAttr;
  inherit (lib) mkIf fakeSha256 mkAfter;
  cfg = config.baseline.gpu;
in
{
  options.baseline.gpu = {
    enable = mkEnableOption "Enable GPU options including nixgl for non nixos hosts";

    enableVulkan = mkEnableOption "Vulkan support in nixgl and nvidia-offload (if enabled)";

    nvidia = {
      enable = mkEnableOption "Enable nvidia nixgl support";

      driverVersion = mkOption {
        type = nullOr str;
        default = null;
        example = "535.154.05";
        description = ''
          The version of the driver that your system is running. This (in combination with `drvierHash`)
          allow the evaluation to be done in pure nix. The cavet is that you need to keep this value in
          sync with the version on your system.

          The driver version can be gotten from `cat /proc/driver/nvidia/version`
        '';
      };

      driverHash = mkOption {
        type = nullOr str;
        default = null;
        example = fakeSha256;
        description = ''
          The hash of the nvidia run file that is pulled to extract the libraries of the it needs to match driver that your system is running.
          This (in combination with `drvierVersion`) allow the evaluation to be done in pure nix. The cavet is that you need to keep this value in
          sync with the version on your system.

          The hash can be gotten by running `nix-prefetch-url https://download.nvidia.com/XFree86/Linux-x86_64/''${driverVersion}/NVIDIA-Linux-x86_64-''${driverVersion}.run"`
        '';
      };

      nixGLPackages = mkOption {
        type = nullOr str;
        default = null;
        example = "\${self}#legacyPackages.\${system}.nixgl";
        description = ''
          The location to pull nixgl from could be ''${self}#legacyPackages.''${system}.nixgl with the nixgl overlay applied or github:nix-community/nixGL#packages.''${system}.

          NOTE: if you pull from the nixGL repo the run will require internet to eval. So nixgl-nvidia / nvidia-offload will not work without internet.
        '';

      };
    };
  };

  config = mkIf cfg.enable (
    let
      impureMode =
        cfg.nvidia.driverHash == null
        && cfg.nvidia.driverVersion == null
        && cfg.nvidia.nixGLPackages != null;
      pureMode = cfg.nvidia.driverHash != null && cfg.nvidia.driverVersion != null;

    in
    {
      assertions = [
        {
          assertion = !cfg.nvidia.enable || impureMode || pureMode;
          message = ''
            nvidia driver is enabled but the nvidia driver version (${
              if cfg.nvidia.driverVersion == null then "null" else cfg.nvidia.driverVersion
            })
            and hash (${
              if cfg.nvidia.driverHash == null then "null" else cfg.nvidia.driverHash
            }) must both be null or both be non-null.

            If they are null impure mode  nixGLPackages (${
              if cfg.nvidia.nixGLPackages == null then "null" else cfg.nvidia.nixGLPackages
            }) must be set must be non-null used otherwise pure eval will be used.
          '';
        }
        {
          assertion = !config.targets.genericLinux.enable || hasAttr "nixgl" pkgs;
          message = ''
            nixgl is missing you need to include the `overlays.default` from nixgl. 
          '';
        }
      ];

      home = {
        # Add helpers for running nixgl to PATH
        packages = [ pkgs.gpu-wrappers ];
        # In impure mode we clear the nixgl cache to ensure that the version is up to date
        activation = mkIf (cfg.nvidia.enable && impureMode) {
          clearNixglCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            [ -v DRY_RUN ] || rm -f ${config.xdg.cacheHome}/nixgl/result*
          '';
        };
      };

      # overlay adds `gpu-wrappers` and ensures that nixgl is in pure mode if available
      # mkAfter is needed because nixgl override needs to be at the end of the list overlays
      nixpkgs.overlays = mkAfter (
        [
          (import ./overlay.nix { inherit config lib; })
        ]
        ++ optional (cfg.nvidia.enable && pureMode) ((import ./nixgl.nix) cfg)
      );
    }
  );
}
