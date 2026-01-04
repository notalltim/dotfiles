{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    getExe
    types
    ;
  cfg = config.baseline.greetd;
in
{
  options.baseline.greetd = {
    enable = mkEnableOption "Enable greetd nixos configuration";
    package = mkOption {
      type = with types; nullOr package;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    services = {
      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${getExe cfg.package} --time --time-format '%I:%M %p | %a • %h | %F' #--cmd \"uwsm start -S hyprland-uwsm.desktop\"";
            user = "greeter";
          };
        };
      };
    };
  };
}
