{ lib, config, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    getExe
    types
    ;
  cfg = config.baseline.greetd;
  c = config.lib.stylix.colors;
  theme = lib.concatStringsSep ";" [
    "border=#${c.base0D}"
    "text=#${c.base05}"
    "prompt=#${c.base0D}"
    "action=#${c.base0C}"
    "button=#${c.base0D}"
    "container=#${c.base00}"
    "input=#${c.base02}"
  ];
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
        useTextGreeter = true;
        settings = {
          default_session = {
            command = "${getExe cfg.package} --time --time-format '%I:%M %p | %a • %h | %F' --cmd 'uwsm start hyprland-uwsm.desktop' --theme ${theme}";
            user = "greeter";
          };
        };
      };
    };
  };
}
