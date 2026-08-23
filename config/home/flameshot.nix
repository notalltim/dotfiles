{
  config,
  lib,
  pkgs,
  baselineLib,
  ...
}:
{
  config = lib.mkIf config.services.flameshot.enable {
    home.packages = with pkgs; [
      # NOTE(tgallion): these are load bearing for some reason
      grim
      slurp
      swappy
    ];
    services.flameshot.settings = {
      General = {
        uiColor = "#${config.lib.stylix.colors.base0E}";
      };

    };
    wayland.windowManager.hyprland.settings = {
      #TODO: Create bindings for sreenshots
      bind = [ (baselineLib.hypr.mkBind null "Print" "Screenshot" "hl.dsp.exec_cmd(\"flameshot gui\")") ];
      window_rule = [
        {
          match.class = "flameshot";
          no_anim = true;
          pin = true;
          float = true;
          decorate = false;
          no_blur = true;
          no_shadow = true;
        }
        {
          match = {
            class = "flameshot";
            title = "flameshot";
          };
          move = [
            0
            0
          ];
        }
        {
          match = {
            class = "flameshot";
            title = "flameshot-pin";
          };
          move = [
            "cursor_x-(window_w*0.5)"
            "cursor_y-(window_h*0.5)"
          ];
        }
      ];
    };
  };
}
