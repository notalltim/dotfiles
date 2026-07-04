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
    environment.systemPackages = [ pkgs.android-tools ];
    programs.obs-studio = {
      enable = true;
      package = null; # Installed via home-manager
      enableVirtualCamera = true;
    };
  };
}
