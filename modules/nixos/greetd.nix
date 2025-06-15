{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.baseline.greetd;
in
{
  options.baseline.greetd = {
    enable = mkEnableOption "Enable greetd nixos configuration";
  };

  config = mkIf cfg.enable {
    services = {
      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' #--cmd \"uwsm start -S hyprland-uwsm.desktop\"";
            user = "greeter";
          };
        };
      };
    };
  };
}
