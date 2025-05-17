{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.baseline.non-nixos;
  gpu = cfg.gpu;
  inherit (lib)
    mkIf
    fakeSha256
    hasAttr
    optionals
    ;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) str nullOr;
in
{
  options.baseline.non-nixos = {
    enable = mkEnableOption "Enable non nixos handling";
    gpu = {
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
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !gpu.nvidia.enable || (cfg.gpu.driverVersion != null && gpu.driverHash != null);
        message = ''
          nvidia driver is enabled but the nvidia driver version (${
            if cfg.nvidia.driverVersion == null then "null" else cfg.nvidia.driverVersion
          })
          and hash (${
            if cfg.nvidia.driverHash == null then "null" else cfg.nvidia.driverHash
          }) must both be null or both be non-null.
        '';
      }
      {
        assertion = hasAttr "nixgl" pkgs;
        message = ''
          nixgl is missing you need to include the `overlays.default` from nixgl. 
        '';
      }
    ];
    programs.home-manager.enable = true;
    systemd.user = {
      startServices = true;
      systemctlPath = "/usr/bin/systemctl";
    };
    targets.genericLinux.enable = true;

    nixGL = {
      packages =
        if gpu.nvidia.enable then
          pkgs.nixgl.override {
            nvidiaVersion = gpu.nvidia.driverVersion;
            nvidiaHash = gpu.nvidia.driverHash;
          }
        else
          pkgs.nixgl;
      vulkan.enable = gpu.enableVulkan;
      installScripts =
        [
          "mesa"
        ]
        ++ optionals (gpu.nvidia.enable) [
          "nvidia"
          "nvidiaPrime"
        ];
      prime = mkIf (gpu.nvidia.enable) {
        nvidiaProvider = "Nvidia-G0";
        installScript = "nvidia";
      };
    };
  };

}
