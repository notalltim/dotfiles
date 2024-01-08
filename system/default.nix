{ config
, pkgs
, lib
, ...
}: {
  config = {
    system-manager.allowAnyDistro = true;
    # Not supported at the moment
    # programs.wireshark.enable = true;
    # nixpkgs.hostPlatform = "x86_64-linux";
  };
}
