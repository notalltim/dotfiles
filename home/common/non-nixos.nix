{ config, lib, ... }:
let
  cfg = config.baseline.non-nixos;
  inherit (lib) mkIf;
  inherit (lib.options) mkEnableOption;
in
{
  options.baseline.non-nixos = {
    enable = mkEnableOption "Enable non nixos handling";
  };

  config = mkIf cfg.enable {
    programs.home-manager.enable = true;
    systemd.user = {
      startServices = true;
      systemctlPath = "/usr/bin/systemctl";
    };
    targets.genericLinux.enable = true;
  };

}
