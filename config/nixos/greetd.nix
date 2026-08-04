{
  lib,
  config,
  pkgs,
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
  settingsFormat = pkgs.formats.toml { };
in
{
  options = {
    programs.tuigreet = {
      settings = mkOption { inherit (settingsFormat) type; };
    };
    baseline.greetd = {
      enable = mkEnableOption "Enable greetd nixos configuration";
      package = mkOption {
        type = with types; nullOr package;
        default = null;
      };
    };
  };
  config = mkIf cfg.enable {

    programs.tuigreet.settings = {
      display = {
        show_time = true;
        time_format = "%I:%M %p | %a • %h | %F";
      };
      # layout.width = 150;

      remember = {
        username = true;
        user_session = true;
      };

      # TODO(fix): this is broken upstream
      # session = {
      #   session_dirs = [
      #     "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
      #   ];
      # };

      theme = mkIf config.stylix.enable {
        container = "black";
        border = "darkgray";
        title = "blue";
        text = "white";
        prompt = "yellow";
        action = "cyan";
        button = "green";
        input = "white";
        time = "magenta";
      };
    };
    services = {
      greetd = {
        enable = true;
        useTextGreeter = true;
        settings = {
          default_session = {
            command = "${getExe cfg.package} --config ${settingsFormat.generate "tuigreet.toml" config.programs.tuigreet.settings} --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
            user = "greeter";
          };
        };
      };
    };
  };
}
