{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.baseline.displays;
in
{
  options.baseline.displays = {
    enable = mkEnableOption "Enable baseline displays configuration";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ddcutil
      ddcui
      brightnessctl
    ];
    services.ddccontrol.enable = true;
  };
}
