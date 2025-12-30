{
  lib,
  config,
  # extraSpecialArgs to map to current user and host
  host,
  user,
  flakeSource ? null,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  inherit (lib.options) mkEnableOption;
  cfg = config.baseline.home-manager;
in
{
  options = {
    baseline.home-manager.enable = mkEnableOption "Enable baseline home-manager configuration";
  };

  config = mkMerge [
    {
      baseline.host = config.baseline.hosts.${host};
      baseline.user = config.baseline.host.users.${user};
      baseline.nix.flakeSource = flakeSource;
    }
    (mkIf cfg.enable {

      xdg.enable = true;

      news.display = "silent";
      manual = {
        html.enable = true;
        json.enable = true;
        manpages.enable = true;
      };
    })
  ];
}
