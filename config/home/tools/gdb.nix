{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  inherit (builtins) hasAttr;
  cfg = config.baseline.gdb;
in
{
  options = {
    baseline.gdb = {
      enable = mkEnableOption "Enable GDB configuration";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasAttr "gcc-pretty-printers" pkgs;
        message = ''
          gcc-pretty-printers is missing you need to include either the `overlays.pretty-printers` 
          or `overlays.default` from the notalltim's flake in the `nixpkgs.overlays` option'';
      }
    ];
    home.packages = [
      pkgs.gdb
      pkgs.valgrind
      (lib.getBin (pkgs.elfutils.override { enableDebuginfod = true; }))
    ];
    home.file.".gdbinit".text = ''
      set debuginfod enabled on
      python
      import sys
      sys.path.insert(0, '${pkgs.gcc-pretty-printers}/python')
      from libstdcxx.v6.printers import register_libstdcxx_printers
      register_libstdcxx_printers (None)
    '';
  };
}
