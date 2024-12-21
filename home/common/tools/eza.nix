{ config, lib, ... }:
let
  inherit (lib) mkIf mkDefault;
  cfg = config.baseline.tools;
in
{
  programs.eza = mkIf cfg.enable {
    enable = mkDefault true;
    enableFishIntegration = mkDefault true;
    git = mkDefault true;
    icons = mkDefault "auto";
  };
}
