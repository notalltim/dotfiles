{ lib, config, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.options) mkEnableOption;
  cfg = config.baseline.home-manager;
in
{
  options = {
    baseline.home-manager.enable = mkEnableOption "Enable baseline home-manager configuration";
  };

  config = mkIf cfg.enable {

    xdg.enable = true;

    news.display = "silent";
    manual = {
      html.enable = true;
      json.enable = true;
      manpages.enable = true;
    };
  };
}
