{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.baseline.audio;
in
{
  options.baseline.audio.enable = mkEnableOption "Enable baseline audio configuration";
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      playerctl
    ];

    # Enable sound with pipewire.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
