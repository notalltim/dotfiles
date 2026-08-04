{ config, lib, ... }:
let

  hasNVMe = lib.any (x: x.driver == "nvme") config.hardware.facter.report.hardware.disk;
in
lib.mkMerge [
  (lib.mkIf config.hardware.facter.detected.graphics.amd.enable {
    hardware.amdgpu.initrd.enable = lib.mkDefault true;
  })
  (lib.mkIf hasNVMe { services.fstrim.enable = lib.mkDefault true; })
]
