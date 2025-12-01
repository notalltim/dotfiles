{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.baseline.host;
in
{
  config = mkIf (cfg.desktopEnvironment == "hyprland") {
    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
      };
      hyprlock.enable = true;
      xwayland.enable = true;
    };

    baseline = {
      greetd.enable = true;
      hyprland = {
        enable = true;
        common = {
          uwsm = true;
          nvidia = true;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      kdePackages.qtwayland
      kdePackages.qtsvg
      adwaita-icon-theme
      adwaita-qt
      adwaita-qt6
      adw-gtk3
    ];
  };
}
