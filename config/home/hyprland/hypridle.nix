{
  config,
  lib,
  pkgs,
  wrapHyprCommand,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optional
    ;
  inherit (lib.types) number nullOr str;
  cfg = config.baseline.hypridle;
in
{
  options.baseline.hypridle = {
    enable = mkEnableOption "Enable hypridle for inactivity timeout management in home-manager";

    lockCommand = mkOption {
      description = "Command that triggers the lock screen";
      type = str;
      default = wrapHyprCommand config.baseline.apps.lock.command;
    };

    lockTimeout = mkOption {
      description = "Seconds until lock screen activates";
      type = nullOr number;
      default = 900;
    };

    monitorTimeout = mkOption {
      description = "Seconds until monitors are turned off";
      type = nullOr number;
      default = 1200;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nixos-artwork.wallpapers.dracula
    ];

    services.hypridle = {
      enable = true;

      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = cfg.lockCommand;
        };

        listener =
          (optional (cfg.lockTimeout != null) {
            timeout = cfg.lockTimeout;
            on-timeout = cfg.lockCommand;
          })
          ++ (optional (cfg.monitorTimeout != null) {
            timeout = cfg.monitorTimeout;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          });
      };
    };
  };
}
