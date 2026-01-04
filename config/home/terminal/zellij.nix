{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.baseline.terminal;
in
{
  programs.zellij = mkIf cfg.enable {
    enable = true;
    enableFishIntegration = true;
    exitShellOnExit = true;
    attachExistingSession = true;
    settings = {
      show_startup_tips = false;
    };
  };
}
