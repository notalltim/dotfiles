{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    mkEnableOption
    ;
  cfg = config.baseline.networking;
in
{
  options.baseline.networking = {
    enable = mkEnableOption "Basline networking config";

  };

  config = mkIf cfg.enable {

    # Interface management
    networking.networkmanager.enable = true;
    baseline.homeCommon.services.network-manager-applet.enable = mkDefault true;
    baseline.userCommon.extraGroups = [
      "networkmanager"
      "wireshark"
    ];
    # mDNS
    services.avahi.enable = true;
    # Debugging
    programs.wireshark = {
      package = pkgs.wireshark;
      enable = true;
      usbmon.enable = true;
    };

  };

}
