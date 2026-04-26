{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.baseline.obs-studio;
in
{
  config = mkIf cfg.anyEnabled {
    programs.droidcam.enable = true;
    programs.adb.enable = true;
    programs.obs-studio = {
      enable = true;
      package = null;

      enableVirtualCamera = true;
    };
  };
}
