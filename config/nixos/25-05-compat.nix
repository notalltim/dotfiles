{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf versionOlder mkMerge;
  inherit (lib.trivial) release;
  enabled = versionOlder release "25.11";
in
{
  config = mkMerge [
    (mkIf enabled {
      baseline.greetd.package = pkgs.greetd.tuigreet;
    })
    (mkIf (!enabled) {
      baseline.greetd.package = pkgs.tuigreet;
    })
  ];
}
