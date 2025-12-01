{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkDefault
    mkMerge
    mkOption
    getExe
    ;
  inherit (lib.types) anything attrsOf;
  cfg = config.baseline.waybar;
in
{
  options.baseline.waybar = {
    enable = mkEnableOption "Enable waybar home-manager configuration";

    settings = mkOption {
      type = attrsOf anything;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    baseline = {
      userModule = _: {
        extraGroups = [ "input" ];
      };
      apps.bar.package = config.programs.waybar.package;
      waybar.settings = mkMerge [
        (with builtins; fromJSON (readFile ./config.json))
        {
          bluetooth.on-click = mkDefault config.baseline.apps.bluetoothManager.command;
          pulseaudio.on-click = mkDefault config.baseline.apps.audioManager.command;
          "custom/session-manager".on-click = mkDefault config.baseline.apps.sessionManager.command;
        }
      ];
    };

    programs = {
      waybar = {
        enable = true;
        settings = [
          cfg.settings
        ];
      };
    };

    systemd.user.services.waybar = {
      Unit.Description = "waybar";
      Install.WantedBy = [ "graphical-session.target" ];
      Unit = {
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = "${getExe config.programs.waybar.package}";
        Restart = "on-failure";
      };
    };
  };
}
