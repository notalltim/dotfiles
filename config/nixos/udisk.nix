{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.services.udisks2;
in
{
  config = mkIf cfg.enable {
    baseline.homeCommon.services.udiskie.enable = true;
  };
}
