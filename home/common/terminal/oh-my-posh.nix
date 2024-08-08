{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.baseline.terminal;
in {
  programs.oh-my-posh = mkIf cfg.enable {
    enable = true;
    enableFishIntegration = true;
    useTheme = "pure";
  };
}
