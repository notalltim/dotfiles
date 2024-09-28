{
  config,
  lib,
  pkgs,
  ...
}:
let
cfg = config.baseline.codeium;
in
{
options = {
  baseline.codeium.enable = mkEnableOption "Enable codeium configuration";


}
}
