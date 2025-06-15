{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkPackageOption mkIf;
  cfg = config.baseline.hyprpolkitagent;
in
{
  options.baseline.hyprpolkitagent = {
    enable = mkEnableOption "Use hyprpolkitagent as the default polkit password prompt service in home-manager";

    package = mkPackageOption pkgs "hyprpolkitagent" { };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Hyprpolkitagent already ships with a systemd service, we just need
    # to put it in the correct place so it will auto-start
    xdg.configFile."systemd/user/graphical-session.target.wants/hyprpolkitagent.service".source =
      "${cfg.package}/share/systemd/user/hyprpolkitagent.service";
  };
}
