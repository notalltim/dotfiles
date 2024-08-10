{
  lib,
  self,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  cfg = config.baseline.gpu;
in {
  options.baseline.gpu = {
    enable = mkEnableOption "Enable GPU overlay";
    enableVulkan = mkEnableOption "Vulkan support";
    enableNvidiaOffload = mkEnableOption "Hybrid graphics support for Nvidia offload";
  };

  config = {
    home = mkIf cfg.enable {
      packages = [pkgs.gpu-wrappers];
      activation = mkIf cfg.enableNvidiaOffload {
        clearNixglCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
          [ -v DRY_RUN ] || rm -f ${config.xdg.cacheHome}/nixgl/result*
        '';
      };
    };
    nixpkgs.overlays = [
      (import ./overlay.nix {inherit self config lib;})
    ];
  };
}
