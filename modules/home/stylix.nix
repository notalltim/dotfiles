{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.baseline.stylix;
in
{
  config = mkIf cfg.enable {
    stylix = {
      targets = {
        firefox.profileNames = [ config.baseline.firefox.profile ];
        nixvim.enable = false;
      };
    };
  };
}
