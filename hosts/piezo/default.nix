{ lib, ... }:
{
  imports = [
    ./hardware.nix
    (./disk.nix)
    {
      _module.args = {
        disk = "/dev/vda";
        withSwap = false;
      };
    }
  ];

  users.users.tgallion = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    initialPassword = "test";
  };
  boot.loader = {
    systemd-boot = {
      enable = true;
      xbootldrMountPoint = "/boot";
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/efi";
    };
    timeout = 3;
  };
  disko.devices.disk.disk0.imageSize = "10G";
  boot.initrd = {
    systemd.enable = true;
  };
  system.stateVersion = "25.05";
}
