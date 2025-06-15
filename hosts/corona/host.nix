{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  baseline = {
    hostNames = [ "corona" ];
    hosts.corona = {
      platform = "nixos";
      users.tgallion.userPubkey = ./id_corona_tgallion.pub;
      hostPubkey = ./ssh_host_ed25519_key.pub;
      desktopEnvironment = "hyprland";
    };
    # monitors.xps15-internal = {
    #   manufacturer = "Sharp Corporation";
    #   height = 1080;
    #   width = 1920;
    #   refreshRate = 60;
    # };
  };

}
