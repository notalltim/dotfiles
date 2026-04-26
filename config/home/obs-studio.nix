{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.baseline.spotify;
in
{
  options.baseline.obs-studio = {
    enable = mkEnableOption "Enable baseline obs-studio";
  };
  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        droidcam-obs
        obs-vaapi
      ];
    };
  };
}
