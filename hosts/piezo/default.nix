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
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  boot.initrd = {
    systemd.enable = true;
  };
  system.stateVersion = "25.05";
}
