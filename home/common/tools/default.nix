{
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkDefault mkIf;
  cfg = config.baseline.tools;
in {
  imports = [./direnv.nix ./eza.nix ./git.nix ./gdb.nix];
  options = {
    baseline.tools.enable = mkEnableOption "Enable baseline set of tools";
  };
  config = mkIf cfg.enable {
    baseline.git.enable = mkDefault true;
    baseline.gdb.enable = mkDefault true;
  };
}
