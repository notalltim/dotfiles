{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
in
{
  config = mkIf config.networking.networkmanager.enable {
    baseline.homeCommon.services.network-manager-applet.enable = mkDefault true;
    baseline.userCommon.extraGroups = [ "networkmanager" ];
  };
}
