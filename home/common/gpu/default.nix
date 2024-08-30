{
  lib,
  self ? { }, # self is required for the impure version of nvidia support
  config,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) str nullOr;
  inherit (lib.lists) optional;
  inherit (builtins) hasAttr;
  inherit (lib) mkIf fakeSha256;
  cfg = config.baseline.gpu;
in
{
  options.baseline.gpu = {
    enable = mkEnableOption "Enable GPU overlay";
    enableVulkan = mkEnableOption "Vulkan support";
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
    };
  };

  config = mkIf cfg.enable (
    let
      bothNull = cfg.nvidia.driverHash == null && cfg.nvidia.driverVersion == null;
      nietherNull = cfg.nvidia.driverHash != null && cfg.nvidia.driverVersion != null;
    in
    {
      assertions = [
        {
          assertion = !cfg.nvidia.enable || bothNull || nietherNull;
          message = ''
            nvidia driver is enabled but the nvidia driver version (${
              if cfg.nvidia.driverVersion == null then "null" else cfg.nvidia.driverVersion
            })
            and hash (${
              if cfg.nvidia.driverHash == null then "null" else cfg.nvidia.driverHash
            }) must both be null or both be non-null.
            If they are null impure mode will be used otherwise pure eval will be used.
          '';
        }
        {
          assertion = hasAttr "nixgl" pkgs;
          message = ''
            nixgl is missing you need to include either the `overlays.nixgl` from nixgl
            or `overlays.default` from notalltim's flake in the `nixpkgs.overlays` option.
          '';
        }
        {
          assertion = !cfg.nvidia.enable || bothNull && (hasAttr "outputs" self) || nietherNull;
          message = ''
            Nvidia is enabled in impure mode and the self has not been passed to `extraSpecialArgs`.          
          '';
        }
        {
          assertion =
            !cfg.nvidia.enable || bothNull && (hasAttr "legacyPackages" self.outputs) || nietherNull;
          message = ''
            The legacyPackages is used to form a nix expression that is run in impure mode as part of the gpu wrapper script          
          '';
        }
        {
          assertion =
            !cfg.nvidia.enable
            || bothNull && (hasAttr "nixgl" self.outputs.legacyPackages.${pkgs.system})
            || nietherNull;
          message = ''
            the nixgl overlay must be applied to `legacyPackages`.
          '';
        }
      ];
      home = {
        packages = [ pkgs.gpu-wrappers ];
        activation = mkIf (cfg.nvidia.enable && bothNull) {
          clearNixglCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            [ -v DRY_RUN ] || rm -f ${config.xdg.cacheHome}/nixgl/result*
          '';
        };
      };
      nixpkgs.overlays =
        [ (import ./overlay.nix { inherit self config lib; }) ]
        ++ optional (cfg.nvidia.enable && nietherNull) [
          (import ./nixgl.nix cfg)
        ]

      ;
    }
  );
}
