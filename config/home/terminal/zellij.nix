{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.baseline.terminal;
in
{
  programs.zellij = mkIf cfg.enable {
    enable = true;
    enableFishIntegration = true;
    # See https://github.com/zellij-org/zellij/issues/3773 but this causes a softlock with multiple sessions
    # exitShellOnExit = true;
    # attachExistingSession = true;
    settings = {
      show_startup_tips = false;
    };
  };
}
