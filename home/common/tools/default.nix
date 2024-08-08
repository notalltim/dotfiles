{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkDefault;
in {
  imports = [./direnv.nix ./eza.nix ./git.nix ./gdb.nix];
  options = {
    baseline.tools.enable = mkEnableOption "Enable baseline set of tools";
  };
  config = {
    baseline.git.enable = mkDefault true;
    baseline.gdb.enable = mkDefault true;
  };
}
