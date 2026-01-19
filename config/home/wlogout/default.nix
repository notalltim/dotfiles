{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.baseline.wlogout;
in
{
  options.baseline.wlogout.enable = mkEnableOption "Enable wlogout home-manager configuration";
  config = mkIf cfg.enable {
    programs.wlogout = {
      enable = true;
      package = pkgs.wleave;
      layout = [
        {
          "label" = "shutdown";
          "action" = "systemctl poweroff";
          "text" = "Shutdown";
          "keybind" = "s";
        }
        {
          "label" = "hibernate";
          "action" = "systemctl hibernate";
          "text" = "Hibernate";
          "keybind" = "h";
        }
        {
          "label" = "reboot";
          "action" = "systemctl reboot";
          "text" = "Reboot";
          "keybind" = "r";
        }
        {
          "label" = "lock";
          "action" = "${config.baseline.apps.lock.command}";
          "text" = "Lock";
          "keybind" = "l";
        }
        {
          "label" = "suspend";
          "action" = "systemctl suspend";
          "text" = "Suspend";
          "keybind" = "s";
        }
        {
          "label" = "logout";
          "action" = "loginctl terminate-user ${config.baseline.user.username}";
          "text" = "Logout";
          "keybind" = "e";
        }
      ];
      style = with config.lib.stylix.colors; ''
        window {
          font-family: "0xProto Nerd Font";
          font-size: 14pt;
          color: #${base05-hex};
          background-color: rgba(${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b}, 0.5);
        }

        button {
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          border: none;
          background-color: rgba(${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b}, 0);
          margin: 5px;
          transition: box-shadow 0.2s ease-in-out, background-color 0.2s ease-in-out;
        }

        button:hover {
          background-color: rgba(${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b}, 0.5);
        }

        button:focus {
          background-color: #${base0E-hex};
          color: #${base00-hex};
        }
      '';
    };
  };
}
