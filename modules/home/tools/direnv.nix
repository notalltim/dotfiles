{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.baseline.tools;
in
{
  programs.direnv = mkIf cfg.enable {
    enable = true;
    nix-direnv.enable = false;
  };
}
