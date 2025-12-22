{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  cfg = config.baseline.debugging;

in
{
  options = {
    baseline.debugging = {
      enable = mkEnableOption "Enable debugging configuration";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.valgrind
    ];
    programs.gdb = {
      enable = true;
      pretty-printers.selected = [
        "eigen"
        "libcxx"
        "libc++"
        "llvm"
      ];
    };
    services.nixseparatedebuginfod.enable = true;
  };
}
