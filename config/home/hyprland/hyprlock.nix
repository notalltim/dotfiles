{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf getExe;
  cfg = config.baseline.hyprpolkitagent;
in
{
  options.baseline.hyprlock = {
    enable = mkEnableOption "Use hyprlock as the default lock screen in home-manager";
  };

  config = mkIf cfg.enable {
    baseline.apps.lock = {
      package = config.programs.hyprlock.package;
      command = "pgrep hyprlock || ${getExe config.programs.hyprlock.package}";
    };

    programs.hyprlock = {
      enable = true;
      settings =
        let
          font = "CaskadiyaCove Nerd Font";
        in
        {
          animations.enable = true;
          auth.fingerprint = {
            enabled = true;
            ready_message = "Scan fingerprint to unlock";
            present_message = "Scanning...";
            retry_delay = 250; # in milliseconds
          };
          input-field = {
            monitor = "";
            size = "20%, 5%";
            outline_thickness = 3;
            fade_on_empty = false;
            rounding = 15;
            font_family = "${font}";
            placeholder_text = "Input password...";
            fail_text = "$PAMFAIL";
            dots_spacing = 0.3;
            position = "0, -20";
            halign = "center";
            valign = "center";
          };
          label = [
            {
              monitor = "";
              text = "cmd[update:60000] date +\"%A, %d %B %Y\": # update every 60 seconds";
              font_size = 25;
              font_family = "Mono";
              position = "-30, -150";
              halign = "right";
              valign = "top";
            }
            {
              monitor = "";
              text = "$TIME"; # ref. https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#variable-substitution
              font_size = 90;
              font_family = "Mono";
              position = "-30, 0";
              halign = "right";
              valign = "top";
            }
          ];
        };
      # extraConfig = builtins.readFile ./config/hyprlock.conf;
    };
  };
}
