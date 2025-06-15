{
  config,
  lib,
  pkgs,
  wrapHyprCommand,
  options,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.baseline.spotify;
in
{
  options.baseline.spotify = {
    enable = mkEnableOption "Enable baseline spotify";
  };
  config = mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      wayland = true;
    };
  };
}
