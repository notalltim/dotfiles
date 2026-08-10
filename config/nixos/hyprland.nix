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

    # bluetooth frontend
    services.blueman.enable = true;
    # disabled in favor of waybar
    # baseline.homeCommon.services.blueman-applet.enable = true;

    baseline = {
      greetd.enable = true;
      hyprland = {
        enable = true;
        common = {
          uwsm = true;
        };
      };
    };

    # TODO: settle on wether to drive this from nixos or home-manager
    # Automatic mounting of removable drives
    services.udisks2.enable = true;
    # Network file shares with nemo
    services.gvfs.enable = true;

    # Allow services to save passwords to a consistent location
    services.gnome.gnome-keyring.enable = true;

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
