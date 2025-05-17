{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.baseline.terminal;
in
{
  programs.zellij = mkIf cfg.enable {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "nightfox";
      show_startup_tips = false;
      themes = {
        nightfox = {
          bg = "#192330";
          fg = "#cdcecf";
          red = "#c94f6d";
          green = "#81b29a";
          blue = "#719cd6";
          yellow = "#dbc074";
          magenta = "#9d79d6";
          orange = "#f4a261";
          cyan = "#63cdcf";
          black = "#29394f";
          white = "#aeafb0";
        };
      };
    };
  };
}
